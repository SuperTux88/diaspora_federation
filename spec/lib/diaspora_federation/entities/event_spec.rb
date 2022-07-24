# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Event do
    let(:location) { Fabricate(:location_entity) }
    let(:data) do
      Fabricate.attributes_for(:event_entity).merge(author: alice.diaspora_id, location: location)
    end

    let(:xml) { <<~XML }
      <event>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <edited_at>#{data[:edited_at].utc.iso8601}</edited_at>
        <summary>#{data[:summary]}</summary>
        <description>#{data[:description]}</description>
        <start>#{data[:start].utc.iso8601}</start>
        <end>#{data[:end].utc.iso8601}</end>
        <all_day>#{data[:all_day]}</all_day>
        <timezone>#{data[:timezone]}</timezone>
        <location>
          <address>#{location.address}</address>
          <lat>#{location.lat}</lat>
          <lng>#{location.lng}</lng>
        </location>
      </event>
    XML

    let(:string) { "Event:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    context "default values" do
      it "uses default values" do
        minimal_xml = <<~XML
          <event>
            <author>#{data[:author]}</author>
            <guid>#{data[:guid]}</guid>
            <summary>#{data[:summary]}</summary>
            <start>#{data[:start].utc.iso8601}</start>
          </event>
        XML

        parsed_xml = Nokogiri::XML(minimal_xml).root
        parsed_instance = Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        expect(parsed_instance.end).to be_nil
        expect(parsed_instance.all_day).to be_falsey
        expect(parsed_instance.timezone).to be_nil
        expect(parsed_instance.description).to be_nil
        expect(parsed_instance.location).to be_nil
      end
    end
  end
end
