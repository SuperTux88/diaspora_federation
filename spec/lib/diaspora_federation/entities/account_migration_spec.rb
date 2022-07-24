# frozen_string_literal: true

module DiasporaFederation
  describe Entities::AccountMigration do
    let(:old_user) { Fabricate(:user) }
    let(:new_user) { Fabricate(:user) }
    let(:old_diaspora_id) { old_user.diaspora_id }
    let(:new_diaspora_id) { new_user.diaspora_id }

    let(:data) {
      hash.dup.tap { |data|
        properties = described_class.new(hash).send(:enriched_properties)
        data[:signature] = properties[:signature]
        data[:profile] = Entities::Profile.new(hash[:profile].to_h.tap { |profile| profile[:edited_at] = nil })
        data[:remote_photo_path] = "http://localhost:3000/uploads/images/"
      }
    }
    let(:signature_data) { "AccountMigration:#{old_diaspora_id}:#{new_diaspora_id}" }
    let(:string) { signature_data }

    shared_examples_for "an account migration entity" do
      it_behaves_like "an Entity subclass"

      it_behaves_like "an XML Entity"

      describe "#to_xml" do
        it "computes signature when no signature was provided" do
          expect_callback(:fetch_private_key, signer_id).and_return(signer_pkey)

          entity = Entities::AccountMigration.new(hash)
          xml = entity.to_xml

          signature = xml.at_xpath("signature").text
          expect(verify_signature(signer_pkey, signature, entity.to_s)).to be_truthy
        end

        it "doesn't change signature if it is already set" do
          hash[:signature] = "aa"

          xml = Entities::AccountMigration.new(hash).to_xml

          expect(xml.at_xpath("signature").text).to eq("aa")
        end

        it "raises when signature isn't set and key isn't supplied" do
          expect_callback(:fetch_private_key, signer_id).and_return(nil)

          expect {
            Entities::AccountMigration.new(hash).to_xml
          }.to raise_error Entities::AccountMigration::PrivateKeyNotFound
        end
      end

      describe "#verify_signature" do
        it "doesn't raise anything if correct signature was passed" do
          hash[:signature] = sign_with_key(signer_pkey, signature_data)
          expect_callback(:fetch_public_key, signer_id).and_return(signer_pkey)
          expect { Entities::AccountMigration.new(hash).verify_signature }.not_to raise_error
        end

        it "raises when no public key for author was fetched" do
          expect_callback(:fetch_public_key, anything).and_return(nil)

          expect {
            Entities::AccountMigration.new(hash).verify_signature
          }.to raise_error Entities::AccountMigration::PublicKeyNotFound
        end

        it "raises when bad author signature was passed" do
          hash[:signature] = "abcdef"

          expect_callback(:fetch_public_key, signer_id).and_return(signer_pkey.public_key)

          expect {
            Entities::AccountMigration.new(hash).verify_signature
          }.to raise_error Entities::AccountMigration::SignatureVerificationFailed
        end
      end

      describe ".from_hash" do
        it "calls #verify_signature" do
          expect_any_instance_of(Entities::AccountMigration).to receive(:freeze)
          expect_any_instance_of(Entities::AccountMigration).to receive(:verify_signature)
          Entities::AccountMigration.from_hash(hash)
        end

        it "raises when bad author signature was passed" do
          hash[:signature] = "abcdef"

          expect_callback(:fetch_public_key, signer_id).and_return(signer_pkey.public_key)

          expect {
            Entities::AccountMigration.from_hash(hash)
          }.to raise_error Entities::AccountMigration::SignatureVerificationFailed
        end
      end
    end

    context "with old identity as author" do
      let(:signer_id) { new_diaspora_id }
      let(:signer_pkey) { new_user.private_key }

      let(:hash) {
        {
          author: old_diaspora_id,
          profile: Fabricate(:profile_entity, author: new_diaspora_id),
          old_identity: old_diaspora_id
        }
      }

      let(:xml) { <<~XML }
        <account_migration>
          <author>#{data[:author]}</author>
          <profile>
            <author>#{data[:profile].author}</author>
            <full_name>#{data[:profile].full_name}</full_name>
            <first_name>#{data[:profile].first_name}</first_name>
            <image_url>#{data[:profile].image_url}</image_url>
            <image_url_medium>#{data[:profile].image_url}</image_url_medium>
            <image_url_small>#{data[:profile].image_url}</image_url_small>
            <bio>#{data[:profile].bio}</bio>
            <birthday>#{data[:profile].birthday}</birthday>
            <gender>#{data[:profile].gender}</gender>
            <location>#{data[:profile].location}</location>
            <searchable>#{data[:profile].searchable}</searchable>
            <public>#{data[:profile].public}</public>
            <nsfw>#{data[:profile].nsfw}</nsfw>
            <tag_string>#{data[:profile].tag_string}</tag_string>
          </profile>
          <signature>#{data[:signature]}</signature>
          <old_identity>#{data[:old_identity]}</old_identity>
          <remote_photo_path>#{data[:remote_photo_path]}</remote_photo_path>
        </account_migration>
      XML

      it_behaves_like "an account migration entity"
    end

    context "with new identity as author" do
      let(:signer_id) { old_diaspora_id }
      let(:signer_pkey) { old_user.private_key }

      let(:hash) {
        {
          author: new_diaspora_id,
          profile: Fabricate(:profile_entity, author: new_diaspora_id),
          old_identity: old_diaspora_id
        }
      }

      let(:xml) { <<~XML }
        <account_migration>
          <author>#{data[:author]}</author>
          <profile>
            <author>#{data[:profile].author}</author>
            <full_name>#{data[:profile].full_name}</full_name>
            <first_name>#{data[:profile].first_name}</first_name>
            <image_url>#{data[:profile].image_url}</image_url>
            <image_url_medium>#{data[:profile].image_url}</image_url_medium>
            <image_url_small>#{data[:profile].image_url}</image_url_small>
            <bio>#{data[:profile].bio}</bio>
            <birthday>#{data[:profile].birthday}</birthday>
            <gender>#{data[:profile].gender}</gender>
            <location>#{data[:profile].location}</location>
            <searchable>#{data[:profile].searchable}</searchable>
            <public>#{data[:profile].public}</public>
            <nsfw>#{data[:profile].nsfw}</nsfw>
            <tag_string>#{data[:profile].tag_string}</tag_string>
          </profile>
          <signature>#{data[:signature]}</signature>
          <old_identity>#{data[:old_identity]}</old_identity>
          <remote_photo_path>#{data[:remote_photo_path]}</remote_photo_path>
        </account_migration>
      XML

      it_behaves_like "an account migration entity"
    end

    context "when author is the new identity and old_identity prop is missing" do
      let(:signer_id) { old_diaspora_id }
      let(:signer_pkey) { old_user.private_key }

      let(:hash) {
        {
          author: new_diaspora_id,
          profile: Fabricate(:profile_entity, author: new_diaspora_id)
        }
      }

      let(:xml) { <<~XML }
        <account_migration>
          <author>#{data[:author]}</author>
          <profile>
            <author>#{data[:profile].author}</author>
            <full_name>#{data[:profile].full_name}</full_name>
            <first_name>#{data[:profile].first_name}</first_name>
            <image_url>#{data[:profile].image_url}</image_url>
            <image_url_medium>#{data[:profile].image_url}</image_url_medium>
            <image_url_small>#{data[:profile].image_url}</image_url_small>
            <bio>#{data[:profile].bio}</bio>
            <birthday>#{data[:profile].birthday}</birthday>
            <gender>#{data[:profile].gender}</gender>
            <location>#{data[:profile].location}</location>
            <searchable>#{data[:profile].searchable}</searchable>
            <public>#{data[:profile].public}</public>
            <nsfw>#{data[:profile].nsfw}</nsfw>
            <tag_string>#{data[:profile].tag_string}</tag_string>
          </profile>
          <signature>#{data[:signature]}</signature>
        </account_migration>
      XML

      it "fails validation on construction" do
        expect {
          described_class.new(hash)
        }.to raise_error Entity::ValidationError
      end

      it "fails validation on parsing" do
        expect {
          parsed_xml = Nokogiri::XML(xml).root
          Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        }.to raise_error Entity::ValidationError
      end
    end

    context "optional values" do
      let(:hash) {
        {
          author: old_diaspora_id,
          profile: Entities::Profile.new(author: new_diaspora_id)
        }
      }

      it "uses default values when parsing" do
        minimal_xml = <<~XML
          <account_migration>
            <author>#{data[:author]}</author>
            <profile>
              <author>#{data[:profile].author}</author>
            </profile>
            <signature>#{data[:signature]}</signature>
          </account_migration>
        XML

        parsed_xml = Nokogiri::XML(minimal_xml).root
        parsed_instance = Entity.entity_class(parsed_xml.name).from_xml(parsed_xml)
        expect(parsed_instance.old_identity).to eq(data[:author])
        expect(parsed_instance.remote_photo_path).to be_nil
      end

      it "adds old_identity when author is the old identity" do
        expected_xml = <<~XML
          <account_migration>
            <author>#{data[:author]}</author>
            <profile>
              <author>#{data[:profile].author}</author>
              <searchable>true</searchable>
              <public>false</public>
              <nsfw>false</nsfw>
            </profile>
            <signature>#{data[:signature]}</signature>
            <old_identity>#{data[:author]}</old_identity>
          </account_migration>
        XML

        entity = Entities::AccountMigration.new(hash)
        expect(entity.to_xml.to_s.strip).to eq(expected_xml.strip)
      end
    end
  end
end
