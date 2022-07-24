# frozen_string_literal: true

module DiasporaFederation
  describe Salmon::MagicEnvelope do
    let(:sender) { Fabricate.sequence(:diaspora_id) }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "asdf") }
    let(:envelope) { Salmon::MagicEnvelope.new(payload, sender) }

    def sig_subj(env)
      data = Base64.urlsafe_decode64(env.at_xpath("me:env/me:data").content)
      type = env.at_xpath("me:env/me:data")["type"]
      enc = env.at_xpath("me:env/me:encoding").content
      alg = env.at_xpath("me:env/me:alg").content

      [data, type, enc, alg].map { |i| Base64.urlsafe_encode64(i) }.join(".")
    end

    def encrypt_magic_env(magic_env)
      DiasporaFederation::Salmon::AES.generate_key_and_iv.tap do |key|
        magic_env.instance_variable_set(
          "@payload_data", DiasporaFederation::Salmon::AES.encrypt(magic_env.send(:payload_data), key[:key], key[:iv])
        )
      end
    end

    context "sanity" do
      it "constructs an instance" do
        expect {
          Salmon::MagicEnvelope.new(payload, sender)
        }.not_to raise_error
      end

      it "raises an error if the param types are wrong" do
        ["asdf", 1234, :test, false].each do |val|
          expect {
            Salmon::MagicEnvelope.new(val, val)
          }.to raise_error ArgumentError
        end
      end
    end

    describe "#envelop" do
      context "sanity" do
        it "raises an error if the param types are wrong" do
          ["asdf", 1234, :test, false].each do |val|
            expect {
              envelope.envelop(val)
            }.to raise_error ArgumentError
          end
        end
      end

      it "should be an instance of Nokogiri::XML::Document" do
        expect(envelope.envelop(privkey)).to be_an_instance_of Nokogiri::XML::Document
      end

      it "returns a magic envelope of correct structure" do
        env_xml = envelope.envelop(privkey).root
        expect(env_xml.name).to eq("env")

        control = %w[data encoding alg sig]
        env_xml.children.each do |node|
          expect(control).to include(node.name)
          control.reject! { |i| i == node.name }
        end

        expect(control).to be_empty
      end

      it "adds the sender to the signature" do
        key_id = envelope.envelop(privkey).at_xpath("me:env/me:sig")["key_id"]

        expect(Base64.urlsafe_decode64(key_id)).to eq(sender)
      end

      it "adds the data_type" do
        data_type = envelope.envelop(privkey).at_xpath("me:env/me:data")["type"]

        expect(data_type).to eq("application/xml")
      end

      it "signs the payload correctly" do
        env_xml = envelope.envelop(privkey)

        subj = sig_subj(env_xml)
        sig = Base64.urlsafe_decode64(env_xml.at_xpath("me:env/me:sig").content)

        expect(privkey.public_key.verify(OpenSSL::Digest.new("SHA256"), sig, subj)).to be_truthy
      end
    end

    describe ".unenvelop" do
      let(:envelope_root) { envelope.envelop(privkey).root }

      context "sanity" do
        before do
          allow(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key, sender
          ).and_return(privkey.public_key)
        end

        it "works with sane input" do
          expect {
            Salmon::MagicEnvelope.unenvelop(envelope_root, sender)
          }.not_to raise_error
        end

        it "raises an error if the param types are wrong" do
          ["asdf", 1234, :test, false].each do |val|
            expect {
              Salmon::MagicEnvelope.unenvelop(val, val)
            }.to raise_error ArgumentError
          end
        end

        it "verifies the envelope structure" do
          expect {
            Salmon::MagicEnvelope.unenvelop(Nokogiri::XML("<asdf/>").root, sender)
          }.to raise_error Salmon::InvalidEnvelope
        end

        it "raises if missing signature" do
          envelope_root.at_xpath("me:sig").remove
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidEnvelope,
            "missing me:sig"
          )
        end

        it "verifies the signature" do
          other_sender = Fabricate.sequence(:diaspora_id)
          other_key = OpenSSL::PKey::RSA.generate(512)

          expect_callback(:fetch_public_key, other_sender).and_return(other_key)

          expect {
            Salmon::MagicEnvelope.unenvelop(envelope_root, other_sender)
          }.to raise_error Salmon::InvalidSignature
        end

        it "raises if missing data" do
          envelope_root.at_xpath("me:data").remove
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidEnvelope,
            "missing me:data"
          )
        end

        it "raises if missing encoding" do
          envelope_root.at_xpath("me:encoding").remove
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidEncoding,
            "missing encoding"
          )
        end

        it "verifies the encoding" do
          envelope_root.at_xpath("me:encoding").content = "invalid_enc"
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidEncoding,
            "invalid encoding: invalid_enc"
          )
        end

        it "raises if missing algorithm" do
          envelope_root.at_xpath("me:alg").remove
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidAlgorithm,
            "missing algorithm"
          )
        end

        it "verifies the algorithm" do
          envelope_root.at_xpath("me:alg").content = "invalid_alg"
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidAlgorithm,
            "invalid algorithm: invalid_alg"
          )
        end

        it "raises if missing data type" do
          envelope_root.at_xpath("me:data").attributes["type"].remove
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidDataType,
            "missing data type"
          )
        end

        it "verifies the data type" do
          envelope_root.at_xpath("me:data")["type"] = "invalid_type"
          expect { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }.to raise_error(
            Salmon::InvalidDataType,
            "invalid data type: invalid_type"
          )
        end
      end

      context "generated instance" do
        it_behaves_like "a MagicEnvelope instance" do
          subject { Salmon::MagicEnvelope.unenvelop(envelope_root, sender) }
        end
      end

      it "decrypts on the fly, when cipher params are present" do
        expect_callback(:fetch_public_key, sender).and_return(privkey.public_key)

        env = Salmon::MagicEnvelope.new(payload)
        params = encrypt_magic_env(env)
        env_xml = env.envelop(privkey).root

        magic_env = Salmon::MagicEnvelope.unenvelop(env_xml, sender, params)
        expect(magic_env.payload).to be_an_instance_of Entities::TestEntity
        expect(magic_env.payload.test).to eq("asdf")
      end

      context "use key_id from magic envelope" do
        context "generated instance" do
          it_behaves_like "a MagicEnvelope instance" do
            subject { Salmon::MagicEnvelope.unenvelop(envelope_root) }
          end
        end

        it "raises if the magic envelope has no key_id" do
          envelope_root.at_xpath("me:sig").attributes["key_id"].remove

          expect {
            Salmon::MagicEnvelope.unenvelop(envelope_root)
          }.to raise_error Salmon::InvalidEnvelope
        end

        it "raises if the sender key is not found" do
          expect_callback(:fetch_public_key, sender).and_return(nil)

          expect {
            Salmon::MagicEnvelope.unenvelop(envelope_root)
          }.to raise_error Salmon::SenderKeyNotFound
        end
      end
    end
  end
end
