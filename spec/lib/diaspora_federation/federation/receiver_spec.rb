# frozen_string_literal: true

module DiasporaFederation
  describe Federation::Receiver do
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) }

    describe ".receive_public" do
      let(:post) { Fabricate(:status_message_entity) }

      it "parses the entity with magic envelope receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        data = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key).to_xml

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), post.author, nil) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.text).to eq(post.text)
          expect(entity.public).to eq("true")
        end

        described_class.receive_public(data)
      end

      it "redirects exceptions from the receiver" do
        expect { described_class.receive_public("<xml/>") }.to raise_error DiasporaFederation::Salmon::InvalidEnvelope
      end
    end

    describe ".receive_private" do
      let(:post) { Fabricate(:status_message_entity, public: false) }

      it "parses the entity with magic envelope receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        magic_env = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key)
        data = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient_key.public_key)

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), post.author, 1234) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.text).to eq(post.text)
          expect(entity.public).to eq("false")
        end

        described_class.receive_private(data, recipient_key, 1234)
      end

      it "raises when recipient private key is not available" do
        magic_env = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key)
        data = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient_key.public_key)

        expect { described_class.receive_private(data, nil, 1234) }.to raise_error(
          ArgumentError,
          "no recipient key provided"
        )
      end

      it "redirects exceptions from the receiver" do
        invalid_magic_env = Nokogiri.XML("<xml/>").root
        data = Salmon::EncryptedMagicEnvelope.encrypt(invalid_magic_env, recipient_key.public_key)

        expect {
          described_class.receive_private(data, recipient_key, 1234)
        }.to raise_error DiasporaFederation::Salmon::InvalidEnvelope
      end
    end
  end
end
