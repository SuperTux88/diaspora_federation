# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Like do
    let(:parent) { Fabricate(:post, author: bob) }
    let(:parent_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      Fabricate.attributes_for(
        :like_entity,
        author: alice.diaspora_id,
        parent_guid: parent.guid,
        parent_type: parent.entity_type,
        parent: parent_entity
      ).tap { |hash| add_signatures(hash) }
    }

    let(:xml) { <<~XML }
      <like>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <parent_guid>#{parent.guid}</parent_guid>
        <parent_type>#{parent.entity_type}</parent_type>
        <positive>#{data[:positive]}</positive>
        <author_signature>#{data[:author_signature]}</author_signature>
      </like>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "like",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "parent_guid": "#{parent.guid}",
          "author_signature": "#{data[:author_signature]}",
          "parent_type": "#{parent.entity_type}",
          "positive": #{data[:positive]}
        },
        "property_order": [
          "author",
          "guid",
          "parent_guid",
          "parent_type",
          "positive"
        ]
      }
    JSON

    let(:string) { "Like:#{data[:guid]}:Post:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    it_behaves_like "a relayable Entity"

    it_behaves_like "a relayable JSON entity"

    context "invalid XML" do
      it "raises a ValidationError if the parent_type is missing" do
        broken_xml = <<~XML
          <like>
            <parent_guid>#{parent.guid}</parent_guid>
          </like>
        XML

        expect {
          DiasporaFederation::Entities::Like.from_xml(Nokogiri::XML(broken_xml).root)
        }.to raise_error Entity::ValidationError, "Invalid Like! Missing 'parent_type'."
      end

      it "raises a ValidationError if the parent_guid is missing" do
        broken_xml = <<~XML
          <like>
            <parent_type>#{parent.entity_type}</parent_type>
          </like>
        XML

        expect {
          DiasporaFederation::Entities::Like.from_xml(Nokogiri::XML(broken_xml).root)
        }.to raise_error Entity::ValidationError, "Invalid Like! Missing 'parent_guid'."
      end
    end
  end
end
