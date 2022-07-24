# frozen_string_literal: true

module DiasporaFederation
  describe Entity do
    let(:data) { { test1: "asdf", test2: 1234, test3: false, test4: false } }
    let(:guid) { Fabricate.sequence(:guid) }

    it "should extend Entity" do
      expect(Entities::TestDefaultEntity).to be < Entity
    end

    context "creation" do
      it "freezes the instance after initialization" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity).to be_frozen
      end

      context "required properties" do
        it "checks for required properties" do
          expect {
            Entities::TestDefaultEntity.new({})
          }.to raise_error Entity::ValidationError, "TestDefaultEntity: Missing required properties: test1, test2"
        end

        it "adds the guid to the error message if available" do
          expect {
            Entities::TestDefaultEntity.new(guid: guid)
          }.to raise_error Entity::ValidationError,
                           "TestDefaultEntity:#{guid}: Missing required properties: test1, test2"
        end

        it "adds the author to the error message if available" do
          expect {
            Entities::TestDefaultEntity.new(author: alice.diaspora_id)
          }.to raise_error Entity::ValidationError,
                           "TestDefaultEntity from #{alice.diaspora_id}: Missing required properties: test1, test2"
        end
      end

      context "defaults" do
        it "sets the defaults" do
          entity = Entities::TestDefaultEntity.new(test1: "1", test2: "2")
          expect(entity.test3).to be_truthy
        end

        it "handles callable defaults" do
          entity = Entities::TestDefaultEntity.new(test1: "1", test2: "2")
          expect(entity.test4).to be_truthy
        end

        it "uses provided values over defaults" do
          entity = Entities::TestDefaultEntity.new(data)
          expect(entity.test3).to be_falsey
          expect(entity.test4).to be_falsey
        end
      end

      it "sets nil if string is empty" do
        data[:test1] = ""
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.test1).to be_nil
      end

      context "when validating" do
        let(:invalid_data) { { test1: "as;df", test2: nil, test3: "no boolean" } }

        it "validates the entity and raise an error with failed properties if not valid" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError,
                           /Failed validation for TestDefaultEntity for properties:.*test1.*\|.*test2.*\|.*test3/
        end

        it "contains the failed rule" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError, /property: test2, value: nil, rule: not_nil, with params: \{\}/
        end

        it "contains the params of the failed rule" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError, /rule: regular_expression, with params: \{:regex=>.*\}/
        end

        it "adds the guid to the error message if available" do
          expect {
            Entities::TestEntityWithAuthorAndGuid.new(test: "invalid", guid: guid, author: alice.diaspora_id)
          }.to raise_error Entity::ValidationError,
                           /Failed validation for TestEntityWithAuthorAndGuid:#{guid} from .* for properties:.*/
        end

        it "handles missing guid" do
          expect {
            Entities::TestEntityWithAuthorAndGuid.new(test: "invalid", guid: nil, author: alice.diaspora_id)
          }.to raise_error Entity::ValidationError,
                           /Failed validation for TestEntityWithAuthorAndGuid: from .* for properties:.*/
        end

        it "adds the author to the error message if available" do
          expect {
            Entities::TestEntityWithAuthorAndGuid.new(test: "invalid", guid: guid, author: alice.diaspora_id)
          }.to raise_error Entity::ValidationError,
                           /Failed validation for .* from #{alice.diaspora_id} for properties:.*/
        end

        it "handles missing author" do
          expect {
            Entities::TestEntityWithAuthorAndGuid.new(test: "invalid", guid: guid, author: nil)
          }.to raise_error Entity::ValidationError,
                           /Failed validation for .* from  for properties:.*/
        end
      end
    end

    describe "#to_h" do
      it "returns a hash of the internal data" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_h).to eq(
          data.to_h { |key, value| [key, entity.class.class_props[key] == :string ? value.to_s : value] }
        )
      end
    end

    describe "#to_xml" do
      it "returns an Nokogiri::XML::Element" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_xml).to be_an_instance_of Nokogiri::XML::Element
      end

      it "has the root node named after the class (underscored)" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_xml.name).to eq("test_default_entity")
      end

      it "contains nodes for each of the properties" do
        entity = Entities::TestDefaultEntity.new(data)
        xml_children = entity.to_xml.children
        expect(xml_children).to have_exactly(4).items
        xml_children.each do |node|
          expect(%w[test1 test2 test3 test4]).to include(node.name)
        end
      end

      context "optional properties" do
        it "contains nodes for optional properties when not nil" do
          entity = Entities::TestOptionalEntity.new(test1: "aa", test2: "bb")
          xml_children = entity.to_xml.children
          expect(xml_children).to have_exactly(2).items
          xml_children.each do |node|
            expect(%w[test1 test2]).to include(node.name)
          end
        end

        it "contains no nodes for optional nil properties" do
          entity = Entities::TestOptionalEntity.new(test2: "bb")
          xml_children = entity.to_xml.children
          expect(xml_children).to have_exactly(1).items
          xml_children.each do |node|
            expect(%w[test2]).to include(node.name)
          end
        end

        it "contains nodes for non optional properties when nil" do
          entity = Entities::TestOptionalEntity.new(test1: "aa", test2: nil)
          xml_children = entity.to_xml.children
          expect(xml_children).to have_exactly(2).items
          xml_children.each do |node|
            expect(%w[test1 test2]).to include(node.name)
          end
        end
      end

      it "replaces invalid XML characters" do
        entity = Entities::TestEntity.new(test: "asdfasdf asdf💩asdf\nasdf")
        xml = entity.to_xml.to_xml
        parsed = Entities::TestEntity.from_xml(Nokogiri::XML(xml).root).test
        expect(parsed).to eq("asdf�asdf asdf💩asdf\nasdf")
      end
    end

    describe ".from_xml" do
      let(:entity) { Entities::TestEntity.new(test: "asdf") }
      let(:entity_xml) { entity.to_xml }

      context "returned object" do
        subject { Entities::TestEntity.from_xml(entity_xml) }

        it "#to_h should match entity.to_h" do
          expect(subject.to_h).to eq(entity.to_h)
        end

        it "returns an entity instance of the original class" do
          expect(subject).to be_an_instance_of Entities::TestEntity
          expect(subject.test).to eq("asdf")
        end
      end

      it "calls .from_hash with the hash representation of provided XML" do
        expect(Entities::TestDefaultEntity).to receive(:from_hash).with(
          test1: "asdf",
          test2: "qwer",
          test3: true
        )
        Entities::TestDefaultEntity.from_xml(Nokogiri::XML(<<~XML).root)
          <test_default_entity>
            <test1>asdf</test1>
            <test2>qwer</qwer2>
            <test3>true</qwer3>
          </test_default_entity>
        XML
      end

      it "forms .from_hash arguments basing on parse return array" do
        arguments = [{ arg1: "value" }]
        expect_any_instance_of(DiasporaFederation::Parsers::XmlParser).to receive(:parse).and_return(arguments)
        expect(Entities::TestDefaultEntity).to receive(:from_hash).with(*arguments)
        Entities::TestDefaultEntity.from_xml(Nokogiri::XML("<dummy/>").root)
      end

      it "passes input parameter directly to .parse method of the parser" do
        root = Nokogiri::XML("<dummy/>").root
        expect_any_instance_of(DiasporaFederation::Parsers::XmlParser)
          .to receive(:parse).with(root).and_return([{ test1: "2", test2: "1" }])
        Entities::TestDefaultEntity.from_xml(root)
      end
    end

    describe "#to_json" do
      let(:basic_props) do
        {
          test1: "123",
          test2: false,
          test3: "456",
          test4: 789,
          test5: Time.now.utc
        }
      end

      let(:hash) do
        basic_props.merge(
          test6: {
            test: "000"
          },
          multi: [
            { asdf: "01" },
            { asdf: "02" }
          ]
        )
      end
      let(:entity_class) { Entities::TestComplexEntity }

      it "generates expected JSON data" do
        json_output = entity_class.new(hash).to_json.to_json
        basic_props[:test5] = basic_props[:test5].iso8601
        expect(json_output).to include_json(
          entity_type: "test_complex_entity",
          entity_data: basic_props.merge(
            test6: {
              entity_type: "test_entity",
              entity_data: {
                test: "000"
              }
            },
            multi: [
              {
                entity_type: "other_entity",
                entity_data: {
                  asdf: "01"
                }
              },
              {
                entity_type: "other_entity",
                entity_data: {
                  asdf: "02"
                }
              }
            ]
          )
        )
      end
    end

    describe ".from_json" do
      it "parses entity properties from the input JSON data" do
        now = change_time(Time.now.utc)
        entity_data = <<~JSON
          {
            "entity_type": "test_complex_entity",
            "entity_data": {
              "test1": "abc",
              "test2": false,
              "test3": "def",
              "test4": 123,
              "test5": "#{now.iso8601}",
              "test6": {
                "entity_type": "test_entity",
                "entity_data": {
                  "test": "nested"
                }
              },
              "multi": [
                {
                  "entity_type": "other_entity",
                  "entity_data": {
                    "asdf": "01"
                  }
                },
                {
                  "entity_type": "other_entity",
                  "entity_data": {
                    "asdf": "02"
                  }
                }
              ]
            }
          }
        JSON

        entity = Entities::TestComplexEntity.from_json(JSON.parse(entity_data))
        expect(entity).to be_an_instance_of(Entities::TestComplexEntity)
        expect(entity.test1).to eq("abc")
        expect(entity.test2).to eq(false)
        expect(entity.test3).to eq("def")
        expect(entity.test4).to eq(123)
        expect(entity.test5).to eq(now)
        expect(entity.test6.test).to eq("nested")
        expect(entity.multi[0].asdf).to eq("01")
        expect(entity.multi[1].asdf).to eq("02")
      end

      it "calls .from_hash with the entity_data of json hash" do
        json = {
          "entity_type" => "test_entity",
          "entity_data" => {
            "test" => "value"
          }
        }
        expect(Entities::TestEntity).to receive(:json_parser_class).and_call_original
        expect_any_instance_of(Parsers::JsonParser).to receive(:parse).with(json).and_call_original
        expect(Entities::TestEntity).to receive(:from_hash).with(test: "value")
        Entities::TestEntity.from_json(json)
      end

      it "forms .from_hash arguments basing on parse return array" do
        class EntityWithFromHashMethod < Entity
          def self.from_hash(_arg1, _arg2, _arg3); end
        end

        expect(EntityWithFromHashMethod).to receive(:json_parser_class).and_call_original
        expect_any_instance_of(Parsers::JsonParser).to receive(:parse).with("{}").and_return(%i[arg1 arg2 arg3])
        expect(EntityWithFromHashMethod).to receive(:from_hash).with(:arg1, :arg2, :arg3)
        EntityWithFromHashMethod.from_json("{}")
      end
    end

    describe ".from_hash" do
      it "parses entity properties from the input data" do
        now = change_time(Time.now.utc)
        entity_data = {
          test1: "abc",
          test2: false,
          test3: "def",
          test4: 123,
          test5: now,
          test6: {
            test: "nested"
          },
          multi: [
            { asdf: "01" },
            { asdf: "02" }
          ]
        }

        entity = Entities::TestComplexEntity.from_hash(entity_data)
        expect(entity).to be_an_instance_of(Entities::TestComplexEntity)
        expect(entity.test1).to eq("abc")
        expect(entity.test2).to eq(false)
        expect(entity.test3).to eq("def")
        expect(entity.test4).to eq(123)
        expect(entity.test5).to eq(now)
        expect(entity.test6.test).to eq("nested")
        expect(entity.multi[0].asdf).to eq("01")
        expect(entity.multi[1].asdf).to eq("02")
      end

      it "calls a constructor of the entity of the appropriate type" do
        entity_data = { test1: "abc", test2: "123" }
        expect(Entities::TestDefaultEntity).to receive(:new).with(test1: "abc", test2: "123")
        Entities::TestDefaultEntity.from_hash(entity_data)
      end

      it "supports instantiation of nested entities using objects of the respective type" do
        entity1 = Entities::TestEntity.new(test: "hello")
        entity2 = Entities::OtherEntity.new(asdf: "01")
        entity3 = Entities::OtherEntity.new(asdf: "02")
        entity_data = {
          asdf: "value",
          test: entity1,
          multi: [entity2, entity3]
        }
        entity = Entities::TestNestedEntity.from_hash(entity_data)
        expect(entity.test).to eq(entity1)
        expect(entity.multi[0]).to eq(entity2)
        expect(entity.multi[1]).to eq(entity3)
      end
    end

    describe ".entity_name" do
      it "strips the module and returns the name underscored" do
        expect(Entities::TestDefaultEntity.entity_name).to eq("test_default_entity")
        expect(Entities::TestNestedEntity.entity_name).to eq("test_nested_entity")
        expect(Entities::OtherEntity.entity_name).to eq("other_entity")
      end

      it "works with a single word" do
        expect(Entities::Entity.entity_name).to eq("entity")
      end
    end

    describe ".entity_class" do
      it "should parse a single word" do
        expect(Entity.entity_class("entity")).to eq(Entities::Entity)
      end

      it "should parse with underscore" do
        expect(Entity.entity_class("test_entity")).to eq(Entities::TestEntity)
      end

      it "should not change the input string" do
        entity_name = "test_entity"
        Entity.entity_class(entity_name)
        expect(entity_name).to eq("test_entity")
      end

      it "raises an error when the entity name contains special characters" do
        expect {
          Entity.entity_class("te.st-enti/ty")
        }.to raise_error Entity::InvalidEntityName, "'te.st-enti/ty' is invalid"
      end

      it "raises an error when the entity name contains upper case letters" do
        expect {
          Entity.entity_class("TestEntity")
        }.to raise_error Entity::InvalidEntityName, "'TestEntity' is invalid"
      end

      it "raises an error when the entity name contains numbers" do
        expect {
          Entity.entity_class("te5t_ent1ty_w1th_number5")
        }.to raise_error Entity::InvalidEntityName, "'te5t_ent1ty_w1th_number5' is invalid"
      end

      it "raises an error when the entity is unknown" do
        expect {
          Entity.entity_class("unknown_entity")
        }.to raise_error Entity::UnknownEntity, "'UnknownEntity' not found"
      end
    end

    context "nested entities" do
      let(:nested_data) do
        {
          asdf: "FDSA",
          test: Entities::TestEntity.new(test: "test"),
          multi: [Entities::OtherEntity.new(asdf: "asdf"), Entities::OtherEntity.new(asdf: "asdf")]
        }
      end
      let(:nested_hash) do
        {
          asdf: nested_data[:asdf],
          test: nested_data[:test].to_h,
          multi: nested_data[:multi].map(&:to_h)
        }
      end

      it "gets returned as Hash by #to_h" do
        entity = Entities::TestNestedEntity.new(nested_data)

        expect(entity.to_h).to eq(nested_hash)
      end

      it "gets xml-ified by #to_xml" do
        entity = Entities::TestNestedEntity.new(nested_data)
        xml = entity.to_xml
        expect(xml.children).to have_exactly(4).items
        xml.children.each do |node|
          expect(%w[asdf test_entity other_entity]).to include(node.name)
        end
        expect(xml.xpath("test_entity")).to have_exactly(1).items
        expect(xml.xpath("other_entity")).to have_exactly(2).items
      end

      it "is not added to xml if #to_xml returns nil" do
        entity = Entities::TestEntityWithRelatedEntity.new(test: "test", parent: Fabricate(:related_entity))
        xml = entity.to_xml
        expect(xml.children).to have_exactly(1).items
        xml.children.first.name = "test"
      end

      it "instantiates nested entities if provided as hash" do
        entity = Entities::TestNestedEntity.new(nested_hash)

        expect(entity.test).to be_instance_of(Entities::TestEntity)
        expect(entity.test.test).to eq("test")

        expect(entity.multi).to be_instance_of(Array)
        expect(entity.multi).to have_exactly(2).items
        expect(entity.multi.first).to be_instance_of(Entities::OtherEntity)
        expect(entity.multi.first.asdf).to eq("asdf")
      end

      it "handles empty xml-element for nested entities" do
        xml = <<~XML
          <test_nested_entity>
            <asdf>FDSA</asdf>
            <test_entity/>
            <other_entity/>
          </test_nested_entity>
        XML

        entity = Entities::TestNestedEntity.from_xml(Nokogiri::XML(xml).root)

        expect(entity.asdf).to eq("FDSA")
        expect(entity.test).to be_nil
        expect(entity.multi).to be_empty
      end
    end
  end
end
