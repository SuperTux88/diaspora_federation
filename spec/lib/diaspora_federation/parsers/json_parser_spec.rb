# frozen_string_literal: true

module DiasporaFederation
  describe Parsers::JsonParser do
    describe ".parse" do
      let(:entity_class) { Entities::TestComplexEntity }
      let(:json_parser) { Parsers::JsonParser.new(entity_class) }

      it "raises error when the entity class doesn't match the entity_type property" do
        expect {
          json_parser.parse(JSON.parse(<<~JSON
            {
              "entity_type": "unknown_entity",
              "entity_data": {}
            }
          JSON
                                      ))
        }.to raise_error(
          DiasporaFederation::Parsers::BaseParser::InvalidRootNode,
          "'unknown_entity' can't be parsed by #{entity_class}"
        )
      end

      include_examples ".parse parse error",
                       "Required properties are missing in JSON object: entity_type",
                       '{"entity_data": {}}'

      include_examples ".parse parse error",
                       "Required properties are missing in JSON object: entity_data",
                       '{"entity_type": "test_complex_entity"}'

      it "returns a hash for the correct JSON input" do
        now = change_time(Time.now.utc)
        json = <<~JSON
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
        hash = json_parser.parse(JSON.parse(json)).first
        expect(hash).to be_a(Hash)
        expect(hash[:test1]).to eq("abc")
        expect(hash[:test2]).to eq(false)
        expect(hash[:test3]).to eq("def")
        expect(hash[:test4]).to eq(123)
        expect(hash[:test5]).to eq(now)
        expect(hash[:test6]).to be_a(Entities::TestEntity)
        expect(hash[:test6].test).to eq("nested")
        expect(hash[:multi]).to be_an(Array)
        expect(hash[:multi][0]).to be_an(Entities::OtherEntity)
        expect(hash[:multi][0].asdf).to eq("01")
        expect(hash[:multi][1].asdf).to eq("02")
      end

      it "doesn't drop extra properties" do
        json = <<~JSON.strip
          {
            "entity_type": "test_default_entity",
            "entity_data": {
              "test1": "abc",
              "test2": false,
              "test3": "def",
              "test_new": "new_value"
            }
          }
        JSON

        parsed = Parsers::JsonParser.new(Entities::TestDefaultEntity).parse(JSON.parse(json))
        expect(parsed[0]["test_new"]).to eq("new_value")
      end
    end
  end
end
