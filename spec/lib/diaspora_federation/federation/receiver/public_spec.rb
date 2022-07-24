# frozen_string_literal: true

module DiasporaFederation
  describe Federation::Receiver::Public do
    let(:post) { Fabricate(:status_message_entity) }
    let(:magic_env) { Salmon::MagicEnvelope.new(post, post.author) }

    describe "#receive" do
      it "receives a public post" do
        expect_callback(:receive_entity, post, post.author, nil)

        described_class.new(magic_env).receive
      end

      it "validates the sender" do
        sender = Fabricate.sequence(:diaspora_id)
        bad_env = Salmon::MagicEnvelope.new(post, sender)

        expect {
          described_class.new(bad_env).receive
        }.to raise_error Federation::Receiver::InvalidSender, "invalid sender: #{sender}"
      end

      context "with relayable" do
        let(:comment) { Fabricate(:comment_entity) }

        it "receives a comment from the author" do
          magic_env = Salmon::MagicEnvelope.new(comment, comment.author)

          expect_callback(:receive_entity, comment, comment.author, nil)

          described_class.new(magic_env).receive
        end

        it "receives a comment from the author parent" do
          magic_env = Salmon::MagicEnvelope.new(comment, comment.parent.author)

          expect_callback(:receive_entity, comment, comment.parent.author, nil)

          described_class.new(magic_env).receive
        end

        it "validates the sender" do
          sender = Fabricate.sequence(:diaspora_id)
          bad_env = Salmon::MagicEnvelope.new(comment, sender)

          expect {
            described_class.new(bad_env).receive
          }.to raise_error Federation::Receiver::InvalidSender, "invalid sender: #{sender}"
        end
      end

      context "with retraction" do
        context "for a post" do
          let(:retraction) { Fabricate(:retraction_entity, target_type: "Post") }

          it "retracts a post from the author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.author)

            expect_callback(:receive_entity, retraction, retraction.author, nil)

            described_class.new(magic_env).receive
          end

          it "validates the sender" do
            sender = Fabricate.sequence(:diaspora_id)
            bad_env = Salmon::MagicEnvelope.new(retraction, sender)

            expect {
              described_class.new(bad_env).receive
            }.to raise_error Federation::Receiver::InvalidSender, "invalid sender: #{sender}"
          end
        end

        context "for a comment" do
          let(:retraction) do
            Fabricate(
              :retraction_entity,
              target_type: "Comment",
              target: Fabricate(:related_entity, parent: Fabricate(:related_entity))
            )
          end

          it "retracts a comment from the author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.target.author)

            expect_callback(:receive_entity, retraction, retraction.target.author, nil)

            described_class.new(magic_env).receive
          end

          it "retracts a comment from the parent author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.target.parent.author)

            expect_callback(:receive_entity, retraction, retraction.target.parent.author, nil)

            described_class.new(magic_env).receive
          end

          it "validates the sender" do
            sender = Fabricate.sequence(:diaspora_id)
            bad_env = Salmon::MagicEnvelope.new(retraction, sender)

            expect {
              described_class.new(bad_env).receive
            }.to raise_error Federation::Receiver::InvalidSender, "invalid sender: #{sender}"
          end
        end
      end

      context "validates if it is public" do
        it "allows public entities" do
          public_post = Fabricate(:status_message_entity, public: true)
          magic_env = Salmon::MagicEnvelope.new(public_post, public_post.author)

          expect_callback(:receive_entity, public_post, public_post.author, nil)

          described_class.new(magic_env).receive
        end

        it "doesn't allow non-public entities" do
          private_post = Fabricate(:status_message_entity, public: false)
          magic_env = Salmon::MagicEnvelope.new(private_post, private_post.author)

          expect {
            described_class.new(magic_env).receive
          }.to raise_error Federation::Receiver::NotPublic
        end

        it "allows entities without public flag" do
          like = Fabricate(:like_entity)
          magic_env = Salmon::MagicEnvelope.new(like, like.author)

          expect_callback(:receive_entity, like, like.author, nil)

          described_class.new(magic_env).receive
        end

        it "allows profiles flagged as private if they don't contain private information" do
          profile = Fabricate(:profile_entity, public: false, bio: nil, birthday: nil, gender: nil, location: nil)
          magic_env = Salmon::MagicEnvelope.new(profile, profile.author)

          expect_callback(:receive_entity, profile, profile.author, nil)

          described_class.new(magic_env).receive
        end

        it "doesn't allow profiles flagged as private if they contain private information" do
          profile = Fabricate(:profile_entity, public: false)
          magic_env = Salmon::MagicEnvelope.new(profile, profile.author)

          expect {
            described_class.new(magic_env).receive
          }.to raise_error Federation::Receiver::NotPublic
        end
      end

      context "with text" do
        before do
          expect(DiasporaFederation.callbacks).to receive(:trigger)
        end

        it "fetches linked entities when the received entity has a text property" do
          expect(Federation::DiasporaUrlParser).to receive(:fetch_linked_entities).with(post.text)

          described_class.new(magic_env).receive
        end

        it "fetches linked entities for the profile bio" do
          profile = Fabricate(:profile_entity, public: true)
          magic_env = Salmon::MagicEnvelope.new(profile, profile.author)

          expect(Federation::DiasporaUrlParser).to receive(:fetch_linked_entities).with(profile.bio)

          described_class.new(magic_env).receive
        end

        it "doesn't try to fetch linked entities when the text is nil" do
          photo = Fabricate(:photo_entity, text: nil)
          magic_env = Salmon::MagicEnvelope.new(photo, photo.author)

          expect(Federation::DiasporaUrlParser).not_to receive(:fetch_linked_entities)

          described_class.new(magic_env).receive
        end
      end
    end
  end
end
