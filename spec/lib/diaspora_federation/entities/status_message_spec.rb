# frozen_string_literal: true

module DiasporaFederation
  describe Entities::StatusMessage do
    let(:photo1) { Fabricate(:photo_entity, author: alice.diaspora_id) }
    let(:photo2) { Fabricate(:photo_entity, author: alice.diaspora_id) }
    let(:location) { Fabricate(:location_entity) }
    let(:data) do
      Fabricate.attributes_for(:status_message_entity).merge(
        author: alice.diaspora_id,
        photos: [photo1, photo2],
        location: location,
        poll: nil,
        event: nil,
        embed: nil,
        provider_display_name: "something"
      )
    end

    let(:xml) { <<~XML }
      <status_message>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <created_at>#{data[:created_at].utc.iso8601}</created_at>
        <public>#{data[:public]}</public>
        <provider_display_name>#{data[:provider_display_name]}</provider_display_name>
        <text>#{data[:text]}</text>
        <edited_at>#{data[:edited_at].utc.iso8601}</edited_at>
        <photo>
          <guid>#{photo1.guid}</guid>
          <author>#{photo1.author}</author>
          <public>#{photo1.public}</public>
          <created_at>#{photo1.created_at.utc.iso8601}</created_at>
          <edited_at>#{photo1.edited_at.utc.iso8601}</edited_at>
          <remote_photo_path>#{photo1.remote_photo_path}</remote_photo_path>
          <remote_photo_name>#{photo1.remote_photo_name}</remote_photo_name>
          <text>#{photo1.text}</text>
          <status_message_guid>#{photo1.status_message_guid}</status_message_guid>
          <height>#{photo1.height}</height>
          <width>#{photo1.width}</width>
        </photo>
        <photo>
          <guid>#{photo2.guid}</guid>
          <author>#{photo2.author}</author>
          <public>#{photo2.public}</public>
          <created_at>#{photo2.created_at.utc.iso8601}</created_at>
          <edited_at>#{photo2.edited_at.utc.iso8601}</edited_at>
          <remote_photo_path>#{photo2.remote_photo_path}</remote_photo_path>
          <remote_photo_name>#{photo2.remote_photo_name}</remote_photo_name>
          <text>#{photo2.text}</text>
          <status_message_guid>#{photo2.status_message_guid}</status_message_guid>
          <height>#{photo2.height}</height>
          <width>#{photo2.width}</width>
        </photo>
        <location>
          <address>#{location.address}</address>
          <lat>#{location.lat}</lat>
          <lng>#{location.lng}</lng>
        </location>
      </status_message>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "status_message",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "created_at": "#{data[:created_at].utc.iso8601}",
          "public": #{data[:public]},
          "provider_display_name": "#{data[:provider_display_name]}",
          "text": "#{data[:text]}",
          "edited_at": "#{data[:edited_at].iso8601}",
          "photos": [
            {
              "entity_type": "photo",
              "entity_data": {
                "guid": "#{photo1.guid}",
                "author": "#{photo1.author}",
                "public": #{photo1.public},
                "created_at": "#{photo1.created_at.utc.iso8601}",
                "edited_at": "#{photo1.edited_at.utc.iso8601}",
                "remote_photo_path": "#{photo1.remote_photo_path}",
                "remote_photo_name": "#{photo1.remote_photo_name}",
                "text": "#{photo1.text}",
                "status_message_guid": "#{photo1.status_message_guid}",
                "height": #{photo1.height},
                "width": #{photo1.width}
              }
            },
            {
              "entity_type": "photo",
              "entity_data": {
                "guid": "#{photo2.guid}",
                "author": "#{photo2.author}",
                "public": #{photo2.public},
                "created_at": "#{photo2.created_at.utc.iso8601}",
                "edited_at": "#{photo2.edited_at.utc.iso8601}",
                "remote_photo_path": "#{photo2.remote_photo_path}",
                "remote_photo_name": "#{photo2.remote_photo_name}",
                "text": "#{photo2.text}",
                "status_message_guid": "#{photo2.status_message_guid}",
                "height": #{photo2.height},
                "width": #{photo2.width}
              }
            }
          ],
          "location": {
            "entity_type": "location",
            "entity_data": {
              "address": "#{location.address}",
              "lat": "#{location.lat}",
              "lng": "#{location.lng}"
            }
          }
        }
      }
    JSON

    let(:string) { "StatusMessage:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "default values" do
      it "uses default values" do
        minimal_xml = <<~XML
          <status_message>
            <author>#{data[:author]}</author>
            <guid>#{data[:guid]}</guid>
            <created_at>#{data[:created_at]}</created_at>
            <text>#{data[:text]}</text>
          </status_message>
        XML

        parsed_xml = Nokogiri.XML(minimal_xml).root
        parsed_instance = Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        expect(parsed_instance.photos).to eq([])
        expect(parsed_instance.location).to be_nil
        expect(parsed_instance.poll).to be_nil
        expect(parsed_instance.event).to be_nil
        expect(parsed_instance.embed).to be_nil
        expect(parsed_instance.public).to be_falsey
        expect(parsed_instance.provider_display_name).to be_nil
      end
    end

    context "nested entities" do
      it "validates that nested photos have the same author" do
        invalid_data = data.merge(author: Fabricate.sequence(:diaspora_id))
        expect { Entities::StatusMessage.new(invalid_data) }.to raise_error Entity::ValidationError
      end
    end
  end
end
