# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Retraction do
    let(:target) { Fabricate(:post, author: bob) }
    let(:target_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:data) do
      Fabricate.attributes_for(
        :retraction_entity,
        target_guid: target.guid,
        target_type: target.entity_type,
        target: target_entity
      )
    end

    let(:xml) { <<~XML }
      <retraction>
        <author>#{data[:author]}</author>
        <target_guid>#{data[:target_guid]}</target_guid>
        <target_type>#{data[:target_type]}</target_type>
      </retraction>
    XML

    let(:string) { "Retraction:#{data[:target_type]}:#{data[:target_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    context "receive with no target found" do
      it "raises when no target is found" do
        unknown_guid = Fabricate.sequence(:guid)
        retraction = Entities::Retraction.new(data.merge(target_guid: unknown_guid))
        expect { described_class.from_xml(retraction.to_xml) }.to raise_error(
          DiasporaFederation::Entities::Retraction::TargetNotFound,
          "not found: #{data[:target_type]}:#{unknown_guid}"
        )
      end
    end

    describe "#sender_valid?" do
      context "unrelayable target" do
        it "allows target author" do
          entity = Entities::Retraction.new(data)

          expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
        end

        it "does not allow any random author" do
          entity = Entities::Retraction.new(data)
          invalid_author = Fabricate.sequence(:diaspora_id)

          expect(entity.sender_valid?(invalid_author)).to be_falsey
        end
      end

      %w[Comment Like PollParticipation].each do |target_type|
        context "#{target_type} target" do
          let(:relayable_target) do
            Fabricate(
              :related_entity,
              author: bob.diaspora_id,
              parent: Fabricate(:related_entity, author: alice.diaspora_id)
            )
          end
          let(:relayable_data) { data.merge(target_type: target_type, target: relayable_target) }
          let(:entity) { Entities::Retraction.new(relayable_data) }

          it "allows target author" do
            expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
          end

          it "allows target parent author" do
            expect(entity.sender_valid?(alice.diaspora_id)).to be_truthy
          end

          it "does not allow any random author" do
            invalid_author = Fabricate.sequence(:diaspora_id)

            expect(entity.sender_valid?(invalid_author)).to be_falsey
          end
        end
      end

      context "Like of a Comment" do
        let(:comment) do
          Fabricate(
            :related_entity,
            author: Fabricate.sequence(:diaspora_id),
            parent: Fabricate(:related_entity, author: alice.diaspora_id)
          )
        end
        let(:relayable_target) { Fabricate(:related_entity, author: bob.diaspora_id, parent: comment) }
        let(:relayable_data) { data.merge(target_type: "Like", target: relayable_target) }
        let(:entity) { Entities::Retraction.new(relayable_data) }

        it "allows target author" do
          expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
        end

        it "allows target root entity author" do
          expect(entity.sender_valid?(alice.diaspora_id)).to be_truthy
        end

        it "does not allow the comment author" do
          expect(entity.sender_valid?(comment.author)).to be_falsey
        end
      end
    end
  end
end
