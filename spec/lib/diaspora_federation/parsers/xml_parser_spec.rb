# frozen_string_literal: true

module DiasporaFederation
  describe Parsers::XmlParser do
    describe ".parse" do
      let(:entity_class) { Entities::TestComplexEntity }
      let(:xml_parser) { Parsers::XmlParser.new(entity_class) }

      it "expects an Nokogiri::XML::Element as param" do
        expect {
          Entities::TestEntity.from_xml(Entities::TestEntity.new(test: "asdf").to_xml)
        }.not_to raise_error
      end

      it "raises an error when the entity class doesn't match the root node" do
        xml = <<~XML
          <unknown_entity>
            <test>asdf</test>
          </unknown_entity>
        XML

        expect {
          xml_parser.parse(Nokogiri::XML(xml).root)
        }.to raise_error Parsers::BaseParser::InvalidRootNode,
                         "'unknown_entity' can't be parsed by DiasporaFederation::Entities::TestComplexEntity"
      end

      it "raises an error when the param is not an Nokogiri::XML::Element" do
        ["asdf", 1234, true, :test].each do |val|
          expect {
            xml_parser.parse(val)
          }.to raise_error ArgumentError, "only Nokogiri::XML::Element allowed"
        end
      end

      it "parses the string to the correct type" do
        xml = <<~XML.strip
          <test_default_entity>
            <test1>asdf</test1>
            <test2>qwer</qwer2>
            <test3>true</qwer3>
          </test_default_entity>
        XML

        parsed = Parsers::XmlParser.new(Entities::TestDefaultEntity).parse(Nokogiri::XML(xml).root)

        expect(parsed[0][:test1]).to eq("asdf")
        expect(parsed[0][:test2]).to eq("qwer")
        expect(parsed[0][:test3]).to eq(true)
      end

      it "parses boolean fields with false value" do
        xml = <<~XML.strip
          <test_entity_with_boolean>
            <test>false</test>
          </test_entity_with_boolean>
        XML

        parsed = Parsers::XmlParser.new(Entities::TestEntityWithBoolean).parse(Nokogiri::XML(xml).root)
        expect(parsed[0][:test]).to eq(false)
      end

      it "parses boolean fields with a randomly matching pattern as nil" do
        %w[ttFFFtt yesFFDSFSDy noDFDSFFDFn fXf LLyes].each do |weird_value|
          xml = <<~XML.strip
            <test_entity_with_boolean>
              <test>#{weird_value}</test>
            </test_entity_with_boolean>
          XML

          parsed = Parsers::XmlParser.new(Entities::TestEntityWithBoolean).parse(
            Nokogiri::XML(xml).root
          )
          expect(parsed[0][:test]).to be_nil
        end
      end

      it "parses integer fields with a randomly matching pattern as nil" do
        %w[1,2,3 foobar two].each do |weird_value|
          xml = <<~XML.strip
            <test_entity_with_integer>
              <test>#{weird_value}</test>
            </test_entity_with_integer>
          XML

          parsed = Parsers::XmlParser.new(Entities::TestEntityWithInteger).parse(
            Nokogiri::XML(xml).root
          )
          expect(parsed[0][:test]).to be_nil
        end
      end

      it "parses timestamp fields with a randomly matching pattern as nil" do
        %w[foobar yesterday now 1.2.foo].each do |weird_value|
          xml = <<~XML.strip
            <test_entity_with_timestamp>
              <test>#{weird_value}</test>
            </test_entity_with_timestamp>
          XML

          parsed = Parsers::XmlParser.new(Entities::TestEntityWithTimestamp).parse(
            Nokogiri::XML(xml).root
          )
          expect(parsed[0][:test]).to be_nil
        end
      end

      context "nested entities" do
        let(:child_entity1) { Entities::TestEntity.new(test: "bla") }
        let(:child_entity2) { Entities::OtherEntity.new(asdf: "blabla") }
        let(:nested_entity) {
          Entities::TestNestedEntity.new(asdf: "QWERT",
                                         test: child_entity1,
                                         multi: [child_entity2, child_entity2])
        }
        let(:nested_payload) { nested_entity.to_xml }

        it "parses the xml with all the nested data" do
          parsed = Parsers::XmlParser.new(Entities::TestNestedEntity).parse(nested_payload)

          expect(parsed[0][:test].to_h).to eq(child_entity1.to_h)
          expect(parsed[0][:multi]).to have(2).items
          expect(parsed[0][:multi].first.to_h).to eq(child_entity2.to_h)
          expect(parsed[0][:asdf]).to eq("QWERT")
        end

        it "parses array entities only once" do
          expect(Entities::OtherEntity).to receive(:from_xml).twice.and_call_original

          parsed = Parsers::XmlParser.new(Entities::TestNestedEntity).parse(nested_payload)

          expect(parsed[0][:multi]).to have(2).items
        end
      end

      it "doesn't drop extra properties" do
        xml = <<~XML.strip
          <test_default_entity>
            <test1>asdf</test1>
            <test2>qwer</test2>
            <test3>true</test3>
            <test_new>new_value</test_new>
          </test_default_entity>
        XML

        parsed = Parsers::XmlParser.new(Entities::TestDefaultEntity).parse(Nokogiri::XML(xml).root)
        expect(parsed[0]["test_new"]).to eq("new_value")
      end
    end
  end
end
