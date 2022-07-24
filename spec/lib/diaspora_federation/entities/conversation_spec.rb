# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Conversation do
    let(:parent) { Fabricate(:conversation, author: bob) }
    let(:parent_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:signed_msg1) do
      Fabricate
        .attributes_for(:message_entity, author: bob.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
        .tap { |hash| add_signatures(hash, Entities::Message) }
    end
    let(:signed_msg2) do
      Fabricate
        .attributes_for(:message_entity, author: bob.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
        .tap { |hash| add_signatures(hash, Entities::Message) }
    end
    let(:data) do
      Fabricate.attributes_for(:conversation_entity).merge!(
        messages: [Entities::Message.new(signed_msg1), Entities::Message.new(signed_msg2)],
        author: bob.diaspora_id,
        guid: parent.guid,
        participants: "#{bob.diaspora_id};#{Fabricate.sequence(:diaspora_id)}"
      )
    end

    let(:xml) { <<~XML }
      <conversation>
        <author>#{data[:author]}</author>
        <guid>#{parent.guid}</guid>
        <subject>#{data[:subject]}</subject>
        <created_at>#{data[:created_at].utc.iso8601}</created_at>
        <participants>#{data[:participants]}</participants>
      #{data[:messages].map { |a| indent(a.to_xml.to_s, 2) }.join("\n")}
      </conversation>
    XML

    let(:string) { "Conversation:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", %i[parent parent_guid]

    context "default values" do
      it "allows no nested messages" do
        minimal_xml = <<~XML
          <conversation>
            <author>#{data[:author]}</author>
            <guid>#{parent.guid}</guid>
            <subject>#{data[:subject]}</subject>
            <created_at>#{data[:created_at]}</created_at>
            <participants>#{data[:participants]}</participants>
          </conversation>
        XML

        parsed_xml = Nokogiri.XML(minimal_xml).root
        parsed_instance = Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        expect(parsed_instance.messages).to eq([])
      end
    end

    context "nested entities" do
      it "validates that nested messages have the same author" do
        invalid_data = data.merge(author: alice.diaspora_id)
        expect { Entities::Conversation.new(invalid_data) }.to raise_error Entity::ValidationError
      end
    end
  end
end
