# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Comment do
    let(:parent) { Fabricate(:post, author: bob) }
    let(:parent_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:data) do
      Fabricate
        .attributes_for(
          :comment_entity,
          author: alice.diaspora_id,
          parent_guid: parent.guid,
          parent: parent_entity
        ).tap { |hash| add_signatures(hash) }
    end

    let(:xml) { <<~XML }
      <comment>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <parent_guid>#{parent.guid}</parent_guid>
        <text>#{data[:text]}</text>
        <created_at>#{data[:created_at].utc.iso8601}</created_at>
        <edited_at>#{data[:edited_at].utc.iso8601}</edited_at>
        <author_signature>#{data[:author_signature]}</author_signature>
      </comment>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "comment",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "parent_guid": "#{parent.guid}",
          "author_signature": "#{data[:author_signature]}",
          "text": "#{data[:text]}",
          "created_at": "#{data[:created_at].iso8601}",
          "edited_at": "#{data[:edited_at].iso8601}"
        },
        "property_order": [
          "author",
          "guid",
          "parent_guid",
          "text",
          "created_at",
          "edited_at"
        ]
      }
    JSON

    let(:string) { "Comment:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", [:created_at]

    it_behaves_like "a JSON Entity"

    it_behaves_like "a relayable Entity"

    it_behaves_like "a relayable JSON entity"
  end
end
