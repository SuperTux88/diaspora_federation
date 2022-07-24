# frozen_string_literal: true

module DiasporaFederation
  describe Salmon::EncryptedMagicEnvelope do
    let(:sender_id) { Fabricate.sequence(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:entity) { Entities::TestEntity.new(test: "abcd") }
    let(:magic_env) { Salmon::MagicEnvelope.new(entity, sender_id).envelop(sender_key) }

    let(:privkey) { OpenSSL::PKey::RSA.generate(1024) } # use small key for speedy specs

    describe ".encrypt" do
      it "creates the json correctly" do
        encrypted = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, privkey.public_key)

        expect(JSON.parse(encrypted)).to include("aes_key", "encrypted_magic_envelope")
      end

      it "encrypts the aes_key correctly" do
        encrypted = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, privkey.public_key)

        json = JSON.parse(encrypted)
        aes_key = JSON.parse(privkey.private_decrypt(Base64.decode64(json["aes_key"])))

        expect(aes_key).to include("key", "iv")
      end

      it "encrypts the magic_envelope correctly" do
        encrypted = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, privkey.public_key)

        json = JSON.parse(encrypted)
        aes_key = JSON.parse(privkey.private_decrypt(Base64.decode64(json["aes_key"])))
        key = aes_key.transform_values { |v| Base64.decode64(v) }

        xml = Salmon::AES.decrypt(json["encrypted_magic_envelope"], key["key"], key["iv"])

        expect(Nokogiri.XML(xml).to_xml).to eq(magic_env.to_xml)
      end
    end

    describe ".decrypt" do
      let(:encrypted_env) { Salmon::EncryptedMagicEnvelope.encrypt(magic_env, privkey.public_key) }

      it "returns the magic envelope xml" do
        decrypted = Salmon::EncryptedMagicEnvelope.decrypt(encrypted_env, privkey)

        expect(decrypted.name).to eq("env")

        expect(decrypted.xpath("me:data")).to have(1).item
        expect(decrypted.xpath("me:encoding")).to have(1).item
        expect(decrypted.xpath("me:alg")).to have(1).item
        expect(decrypted.xpath("me:sig")).to have(1).item
      end
    end
  end
end
