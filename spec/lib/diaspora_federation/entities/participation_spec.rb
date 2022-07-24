# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Participation do
    let(:parent) { Fabricate(:post, author: bob) }
    let(:data) do
      Fabricate.attributes_for(
        :participation_entity,
        author: alice.diaspora_id,
        parent_guid: parent.guid,
        parent_type: parent.entity_type
      )
    end

    let(:xml) { <<~XML }
      <participation>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <parent_guid>#{parent.guid}</parent_guid>
        <parent_type>#{parent.entity_type}</parent_type>
      </participation>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "participation",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "parent_guid": "#{parent.guid}",
          "parent_type": "#{parent.entity_type}"
        }
      }
    JSON

    let(:string) { "Participation:#{data[:guid]}:Post:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "parse xml" do
      describe "#validate_parent" do
        let(:participation) do
          allow(DiasporaFederation.callbacks).to receive(:trigger).and_call_original
          Entities::Participation.new(data)
        end

        it "succeeds when the parent is local" do
          local_parent = Fabricate(:related_entity, local: true)
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(local_parent)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.not_to raise_error
        end

        it "raises ParentNotLocal when the parent is not found" do
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(nil)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.to raise_error Entities::Participation::ParentNotLocal, "obj=#{participation}"
        end

        it "raises ParentNotLocal when the parent is not local" do
          remote_parent = Fabricate(:related_entity, local: false)
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(remote_parent)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.to raise_error Entities::Participation::ParentNotLocal, "obj=#{participation}"
        end
      end
    end
  end
end
