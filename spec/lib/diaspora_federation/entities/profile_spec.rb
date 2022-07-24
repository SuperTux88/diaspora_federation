# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Profile do
    let(:data) { Fabricate.attributes_for(:profile_entity) }

    let(:xml) { <<~XML }
      <profile>
        <author>#{data[:author]}</author>
        <edited_at>#{data[:edited_at].utc.iso8601}</edited_at>
        <full_name>#{data[:full_name]}</full_name>
        <first_name>#{data[:first_name]}</first_name>
        <image_url>#{data[:image_url]}</image_url>
        <image_url_medium>#{data[:image_url]}</image_url_medium>
        <image_url_small>#{data[:image_url]}</image_url_small>
        <bio>#{data[:bio]}</bio>
        <birthday>#{data[:birthday]}</birthday>
        <gender>#{data[:gender]}</gender>
        <location>#{data[:location]}</location>
        <searchable>#{data[:searchable]}</searchable>
        <public>#{data[:public]}</public>
        <nsfw>#{data[:nsfw]}</nsfw>
        <tag_string>#{data[:tag_string]}</tag_string>
      </profile>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "profile",
        "entity_data": {
          "author": "#{data[:author]}",
          "edited_at": "#{data[:edited_at].iso8601}",
          "full_name": "#{data[:full_name]}",
          "first_name": "#{data[:first_name]}",
          "image_url": "#{data[:image_url]}",
          "image_url_medium": "#{data[:image_url]}",
          "image_url_small": "#{data[:image_url]}",
          "bio": "#{data[:bio]}",
          "birthday": "#{data[:birthday]}",
          "gender": "#{data[:gender]}",
          "location": "#{data[:location]}",
          "searchable": #{data[:searchable]},
          "public": #{data[:public]},
          "nsfw": #{data[:nsfw]},
          "tag_string": "#{data[:tag_string]}"
        }
      }
    JSON

    let(:string) { "Profile:#{data[:author]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "default values" do
      it "uses default values" do
        minimal_xml = <<~XML
          <profile>
            <author>#{data[:author]}</author>
          </profile>
        XML

        parsed_xml = Nokogiri.XML(minimal_xml).root
        parsed_instance = Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        expect(parsed_instance.full_name).to be_nil
        expect(parsed_instance.first_name).to be_nil
        expect(parsed_instance.last_name).to be_nil
        expect(parsed_instance.image_url).to be_nil
        expect(parsed_instance.image_url_medium).to be_nil
        expect(parsed_instance.image_url_small).to be_nil
        expect(parsed_instance.birthday).to be_nil
        expect(parsed_instance.gender).to be_nil
        expect(parsed_instance.bio).to be_nil
        expect(parsed_instance.location).to be_nil
        expect(parsed_instance.searchable).to be_truthy
        expect(parsed_instance.public).to be_falsey
        expect(parsed_instance.nsfw).to be_falsey
        expect(parsed_instance.tag_string).to be_nil
      end
    end
  end
end
