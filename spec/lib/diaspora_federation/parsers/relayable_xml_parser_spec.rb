# frozen_string_literal: true

module DiasporaFederation
  describe Parsers::RelayableXmlParser do
    describe ".parse" do
      let(:entity_class) { Entities::SomeRelayable }
      let(:xml_parser) { Parsers::RelayableXmlParser.new(entity_class) }
      it "passes order of the XML elements as a second argument in the returned list" do
        xml_object = Nokogiri.XML(<<~XML).root
          <some_relayable>
            <guid>im a guid</guid>
            <property>value</property>
            <author>id@example.tld</author>
          </some_relayable>
        XML

        parsed_data = xml_parser.parse(xml_object)
        expect(parsed_data[0]).to be_a(Hash)
        expect(parsed_data[0][:guid]).to eq("im a guid")
        expect(parsed_data[0][:property]).to eq("value")
        expect(parsed_data[0][:author]).to eq("id@example.tld")
        expect(parsed_data[1]).to eq(%i[guid property author])
      end
    end
  end
end
