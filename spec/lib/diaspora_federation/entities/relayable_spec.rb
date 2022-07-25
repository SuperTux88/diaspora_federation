# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Relayable do
    let(:author_pkey) { OpenSSL::PKey::RSA.generate(1024) }

    let(:guid) { Fabricate.sequence(:guid) }
    let(:parent_guid) { Fabricate.sequence(:guid) }
    let(:author) { Fabricate.sequence(:diaspora_id) }
    let(:property) { "hello" }
    let(:new_property) { "some text" }
    let(:local_parent) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:remote_parent) { Fabricate(:related_entity, author: bob.diaspora_id, local: false) }
    let(:hash) { { guid: guid, author: author, parent_guid: parent_guid, parent: local_parent, property: property } }
    let(:hash_with_fake_signatures) { hash.merge!(author_signature: "aa") }

    let(:signature_order) { %i[author guid parent_guid property] }
    let(:signature_data) { "#{author};#{guid};#{parent_guid};#{property}" }

    describe "#initialize" do
      it "filters signatures from order" do
        signature_order = [
          :author,
          :guid,
          :parent_guid,
          :property,
          "new_property",
          :author_signature,
          "parent_author_signature"
        ]

        expect(Entities::SomeRelayable.new(hash, signature_order).signature_order).to eq(
          [:author, :guid, :parent_guid, :property, "new_property"]
        )
      end

      it "filters signatures from additional_data" do
        signature_order = [:author, :guid, :parent_guid, :property, "new_property"]
        additional_data = { "new_property" => "foobar", "parent_author_signature" => "bb" }

        expect(Entities::SomeRelayable.new(hash, signature_order, additional_data).additional_data).to eq(
          "new_property" => "foobar"
        )
      end
    end

    describe "#verify_signature" do
      it "doesn't raise anything if correct author_signature was passed" do
        hash[:author_signature] = sign_with_key(author_pkey, signature_data)
        hash[:parent] = remote_parent

        expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)

        expect { Entities::SomeRelayable.new(hash, signature_order).verify_signature }.not_to raise_error
      end

      it "doesn't raise anything if correct author_signature with new property was passed" do
        signature_order = [:author, :guid, :parent_guid, :property, "new_property"]
        signature_data_with_new_property = "#{author};#{guid};#{parent_guid};#{property};#{new_property}"

        hash[:author_signature] = sign_with_key(author_pkey, signature_data_with_new_property)
        hash[:parent] = remote_parent

        expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)

        expect {
          Entities::SomeRelayable.new(hash, signature_order, "new_property" => new_property).verify_signature
        }.not_to raise_error
      end

      it "raises when no public key for author was fetched" do
        expect_callback(:fetch_public_key, anything).and_return(nil)

        expect {
          Entities::SomeRelayable.new(hash, signature_order).verify_signature
        }.to raise_error Entities::Relayable::PublicKeyNotFound
      end

      it "raises when no author signature was passed" do
        hash[:author_signature] = nil

        expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)

        expect {
          Entities::SomeRelayable.new(hash, signature_order).verify_signature
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end

      it "doesn't raise when no author signature was passed, but the author is also the parent author" do
        hash[:author_signature] = nil
        hash[:parent] = Fabricate(:related_entity, author: author, local: false)

        expect { Entities::SomeRelayable.new(hash, signature_order).verify_signature }.not_to raise_error
      end

      it "doesn't raise when no author signature was passed, but the author is also the author of the root entity" do
        hash[:author_signature] = nil
        root = Fabricate(:related_entity, author: author, local: false)
        hash[:parent] = Fabricate(:related_entity, author: Fabricate.sequence(:diaspora_id), local: false, parent: root)

        expect { Entities::SomeRelayable.new(hash, signature_order).verify_signature }.not_to raise_error
      end

      it "raises when bad author signature was passed" do
        hash[:author_signature] = sign_with_key(author_pkey, "bad signed string")

        expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)

        expect {
          Entities::SomeRelayable.new(hash, signature_order).verify_signature
        }.to raise_error Entities::Relayable::SignatureVerificationFailed
      end
    end

    describe "#to_xml" do
      let(:expected_xml) { <<~XML }
        <some_relayable>
          <author>#{author}</author>
          <guid>#{guid}</guid>
          <parent_guid>#{parent_guid}</parent_guid>
          <property>#{property}</property>
          <new_property>#{new_property}</new_property>
          <author_signature>aa</author_signature>
        </some_relayable>
      XML

      it "adds new unknown xml elements to the xml again" do
        signature_order = [:author, :guid, :parent_guid, :property, "new_property"]
        xml =
          Entities::SomeRelayable.new(hash_with_fake_signatures, signature_order, "new_property" => new_property).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "accepts string names of known properties in signature_order" do
        signature_order = %w[author guid parent_guid property new_property]
        xml =
          Entities::SomeRelayable.new(hash_with_fake_signatures, signature_order, "new_property" => new_property).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "adds missing properties from signature_order to xml" do
        signature_order = [:author, :guid, :parent_guid, :property, "new_property"]

        xml = Entities::SomeRelayable.new(hash_with_fake_signatures, signature_order).to_xml

        expect(xml.at_xpath("new_property").text).to be_empty
      end

      it "adds nil properties to xml when needed for signature_order" do
        expected_xml = <<~XML
          <some_relayable>
            <author>#{author}</author>
            <guid>#{guid}</guid>
            <parent_guid>#{parent_guid}</parent_guid>
            <property/>
            <new_property>#{new_property}</new_property>
            <author_signature>aa</author_signature>
          </some_relayable>
        XML

        signature_order = [:author, :guid, :parent_guid, :property, "new_property"]
        xml =
          Entities::SomeRelayable.new(
            hash_with_fake_signatures.merge(property: nil),
            signature_order,
            "new_property" => new_property
          ).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "does not add nil properties to xml when not needed for signature_order" do
        expected_xml = <<~XML
          <some_relayable>
            <author>#{author}</author>
            <guid>#{guid}</guid>
            <parent_guid>#{parent_guid}</parent_guid>
            <author_signature>aa</author_signature>
          </some_relayable>
        XML

        xml = Entities::SomeRelayable.new(hash_with_fake_signatures.merge(property: nil)).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "computes correct author_signature for the entity" do
        expect_callback(:fetch_private_key, author).and_return(author_pkey)

        xml = Entities::SomeRelayable.new(hash).to_xml

        expect(verify_signature(author_pkey, xml.at_xpath("author_signature").text, signature_data)).to be_truthy
      end

      it "computes correct author_signature for the entity with invalid XML characters" do
        expect_callback(:fetch_private_key, author).and_return(author_pkey)

        invalid_property = "asdfasdf asdf💩asdf\nasdf"
        signature_data_with_fixed_property = "#{author};#{guid};#{parent_guid};asdf�asdf asdf💩asdf\nasdf"

        xml = Entities::SomeRelayable.new(hash.merge(property: invalid_property)).to_xml

        author_signature = xml.at_xpath("author_signature").text
        expect(verify_signature(author_pkey, author_signature, signature_data_with_fixed_property)).to be_truthy
      end

      it "computes correct author_signature for the entity when the parent is a relayable itself" do
        intermediate_author = Fabricate.sequence(:diaspora_id)
        parent = Fabricate(:related_entity, author: intermediate_author, local: true, parent: local_parent)
        expect_callback(:fetch_private_key, author).and_return(author_pkey)
        expect(DiasporaFederation.callbacks).not_to receive(:trigger).with(:fetch_private_key, intermediate_author)

        xml = Entities::SomeRelayable.new(hash.merge(parent: parent)).to_xml

        expect(verify_signature(author_pkey, xml.at_xpath("author_signature").text, signature_data)).to be_truthy
      end

      it "computes correct author_signature for the entity with new unknown xml elements" do
        expect_callback(:fetch_private_key, author).and_return(author_pkey)

        signature_order = [:author, :guid, :parent_guid, "new_property", :property]
        signature_data_with_new_property = "#{author};#{guid};#{parent_guid};#{new_property};#{property}"

        xml = Entities::SomeRelayable.new(hash, signature_order, "new_property" => new_property).to_xml

        author_signature = xml.at_xpath("author_signature").text
        expect(verify_signature(author_pkey, author_signature, signature_data_with_new_property)).to be_truthy
      end

      it "doesn't change author_signature if it is already set" do
        xml = Entities::SomeRelayable.new(hash_with_fake_signatures).to_xml

        expect(xml.at_xpath("author_signature").text).to eq("aa")
      end

      it "raises when author_signature not set and key isn't supplied" do
        expect_callback(:fetch_private_key, author).and_return(nil)

        expect { Entities::SomeRelayable.new(hash).to_xml }.to raise_error Entities::Relayable::AuthorPrivateKeyNotFound
      end

      it "does not add author_signature when author is also the root author" do
        expected_xml = <<~XML
          <some_relayable>
            <author>#{author}</author>
            <guid>#{guid}</guid>
            <parent_guid>#{parent_guid}</parent_guid>
            <property>#{property}</property>
          </some_relayable>
        XML

        xml = Entities::SomeRelayable.new(hash.merge(parent: Fabricate(:related_entity, author: author))).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end

      it "adds 'false' booleans" do
        expected_xml = <<~XML
          <test_relayable_with_boolean>
            <author>#{author}</author>
            <guid>#{guid}</guid>
            <parent_guid>#{parent_guid}</parent_guid>
            <test>false</test>
            <author_signature>aa</author_signature>
          </test_relayable_with_boolean>
        XML

        xml = Entities::TestRelayableWithBoolean.new(hash_with_fake_signatures.merge(test: false)).to_xml

        expect(xml.to_s.strip).to eq(expected_xml.strip)
      end
    end

    describe ".from_xml" do
      context "parsing" do
        before do
          expect_callback(:fetch_related_entity, "Parent", parent_guid).and_return(remote_parent)
          expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)
        end

        let(:new_signature_data) { "#{author};#{guid};#{parent_guid};#{new_property};#{property}" }
        let(:new_xml) { <<~XML }
          <some_relayable>
            <author>#{author}</author>
            <guid>#{guid}</guid>
            <parent_guid>#{parent_guid}</parent_guid>
            <new_property>#{new_property}</new_property>
            <property>#{property}</property>
            <author_signature>#{sign_with_key(author_pkey, new_signature_data)}</author_signature>
          </some_relayable>
        XML

        it "doesn't drop unknown properties" do
          entity = Entities::SomeRelayable.from_xml(Nokogiri.XML(new_xml).root)

          expect(entity).to be_an_instance_of Entities::SomeRelayable
          expect(entity.property).to eq(property)
          expect(entity.additional_data).to eq("new_property" => new_property)
        end

        it "hand over the order in the xml to the instance without signatures" do
          entity = Entities::SomeRelayable.from_xml(Nokogiri.XML(new_xml).root)

          expect(entity.signature_order).to eq([:author, :guid, :parent_guid, "new_property", :property])
        end

        it "creates Entity with empty 'additional_data' if the xml has only known properties" do
          hash[:author_signature] = sign_with_key(author_pkey, signature_data)

          xml = Entities::SomeRelayable.new(hash).to_xml

          entity = Entities::SomeRelayable.from_xml(xml)

          expect(entity).to be_an_instance_of Entities::SomeRelayable
          expect(entity.property).to eq(property)
          expect(entity.additional_data).to be_empty
        end
      end

      context "parse invalid XML" do
        it "raises a ValidationError if the parent_guid is missing" do
          broken_xml = <<~XML
            <some_relayable>
            </some_relayable>
          XML

          expect {
            Entities::SomeRelayable.from_xml(Nokogiri.XML(broken_xml).root)
          }.to raise_error Entity::ValidationError, "Invalid SomeRelayable! Missing 'parent_guid'."
        end

        it "adds the guid to the error message if available" do
          broken_xml = <<~XML
            <some_relayable>
              <guid>#{guid}</guid>
            </some_relayable>
          XML

          expect {
            Entities::SomeRelayable.from_xml(Nokogiri.XML(broken_xml).root)
          }.to raise_error Entity::ValidationError, "Invalid SomeRelayable:#{guid}! Missing 'parent_guid'."
        end

        it "adds the author to the error message if available" do
          broken_xml = <<~XML
            <some_relayable>
              <author>#{author}</author>
            </some_relayable>
          XML

          expect {
            Entities::SomeRelayable.from_xml(Nokogiri.XML(broken_xml).root)
          }.to raise_error Entity::ValidationError, "Invalid SomeRelayable from #{author}! Missing 'parent_guid'."
        end
      end
    end

    describe "#to_json" do
      let(:entity_class) { Entities::SomeRelayable }

      it "contains the property order within the property_order property" do
        property_order = %i[author guid parent_guid property]
        json = entity_class.new(hash_with_fake_signatures, property_order).to_json.to_json

        expect(json).to include_json(property_order: property_order.map(&:to_s))
      end

      it "uses property order for filling property_order when no signature_order supplied" do
        entity = entity_class.new(hash_with_fake_signatures)
        expect(entity.to_json.to_json).to include_json(property_order: %w[author guid parent_guid property])
      end

      it "adds new unknown elements to the json again" do
        property_order = [:author, :guid, :parent_guid, :property, "new_property"]
        json =
          Entities::SomeRelayable
            .new(hash_with_fake_signatures, property_order, "new_property" => new_property)
            .to_json
            .to_json

        expect(json).to include_json(
          entity_data: {
            new_property: new_property
          },
          property_order: {
            4 => "new_property"
          }
        )
      end

      it "adds missing properties from property order to json" do
        property_order = [:author, :guid, :parent_guid, :property, "new_property"]
        json = Entities::SomeRelayable.new(hash_with_fake_signatures, property_order).to_json.to_json

        expect(json).to include_json(entity_data: { new_property: nil }, property_order: { 4 => "new_property" })
      end

      it "computes correct author_signature for the entity with new unknown elements" do
        expect_callback(:fetch_private_key, author).and_return(author_pkey)

        property_order = [:author, :guid, :parent_guid, "new_property", :property]
        signature_data_with_new_property = "#{author};#{guid};#{parent_guid};#{new_property};#{property}"

        json_hash = Entities::SomeRelayable.new(hash, property_order, "new_property" => new_property).to_json
        author_signature = json_hash[:entity_data][:author_signature]

        expect(verify_signature(author_pkey, author_signature, signature_data_with_new_property)).to be_truthy
      end

      it "doesn't change author_signature if it is already set" do
        json = Entities::SomeRelayable.new(hash_with_fake_signatures).to_json.to_json
        expect(json).to include_json(entity_data: { author_signature: "aa" })
      end

      it "raises when author_signature not set and key isn't supplied" do
        expect_callback(:fetch_private_key, author).and_return(nil)

        expect {
          Entities::SomeRelayable.new(hash).to_json
        }.to raise_error Entities::Relayable::AuthorPrivateKeyNotFound
      end
    end

    describe ".from_hash" do
      let(:entity_class) { Entities::SomeRelayable }

      context "parsing" do
        before do
          expect_callback(:fetch_related_entity, "Parent", parent_guid).and_return(remote_parent)
          expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)
        end

        context "when properties are sorted and there is an unknown property" do
          let(:new_signature_data) { "#{author};#{guid};#{parent_guid};#{new_property};#{property}" }
          let(:author_signature) { sign_with_key(author_pkey, new_signature_data) }
          let(:entity_data) do
            {
              :guid => guid,
              :author => author,
              :property => property,
              :parent_guid => parent_guid,
              "new_property" => new_property,
              :author_signature => author_signature
            }
          end
          let(:property_order) { %w[author guid parent_guid new_property property] }

          it "parses entity properties from the input data" do
            entity = Entities::SomeRelayable.from_hash(entity_data, property_order)
            expect(entity).to be_an_instance_of Entities::SomeRelayable
            expect(entity.author).to eq(author)
            expect(entity.guid).to eq(guid)
            expect(entity.parent_guid).to eq(parent_guid)
            expect(entity.property).to eq(property)
            expect(entity.author_signature).to eq(author_signature)
          end

          it "makes unknown properties available via #additional_data" do
            entity = Entities::SomeRelayable.from_hash(entity_data, property_order)
            expect(entity.additional_data).to eq("new_property" => new_property)
          end

          it "hands over the order in the data to the instance without signatures" do
            entity = Entities::SomeRelayable.from_hash(entity_data, property_order)
            expect(entity.signature_order).to eq([:author, :guid, :parent_guid, "new_property", :property])
          end

          it "calls a constructor of the entity of the appropriate type" do
            expect(Entities::SomeRelayable).to receive(:new).with(
              {
                author: author,
                guid: guid,
                parent_guid: parent_guid,
                property: property,
                author_signature: author_signature,
                parent: remote_parent
              }.merge("new_property" => new_property),
              %w[author guid parent_guid new_property property],
              "new_property" => new_property
            ).and_call_original
            Entities::SomeRelayable.from_hash(entity_data, property_order)
          end
        end

        it "creates Entity with empty 'additional_data' if it has only known properties" do
          property_order = %w[author guid parent_guid property]

          entity_data = {
            guid: guid,
            author: author,
            property: property,
            parent_guid: parent_guid,
            author_signature: sign_with_key(author_pkey, signature_data)
          }

          entity = Entities::SomeRelayable.from_hash(entity_data, property_order)

          expect(entity).to be_an_instance_of Entities::SomeRelayable
          expect(entity.additional_data).to be_empty
        end
      end

      context "relayable signature verification feature support" do
        it "calls signatures verification on relayable unpack" do
          property_order = %w[guid author property parent_guid]
          entity_data = {
            guid: guid,
            author: author,
            property: property,
            parent_guid: parent_guid,
            author_signature: "aa"
          }

          expect_callback(:fetch_related_entity, "Parent", parent_guid).and_return(remote_parent)
          expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)
          expect {
            Entities::SomeRelayable.from_hash(entity_data, property_order)
          }.to raise_error DiasporaFederation::Entities::Relayable::SignatureVerificationFailed
        end
      end

      context "fetch parent" do
        before do
          expect_callback(:fetch_public_key, author).and_return(author_pkey.public_key)
          expect_callback(:fetch_private_key, author).and_return(author_pkey)
        end

        let(:entity) { Entities::SomeRelayable.new(hash) }
        let(:data) { entity.to_h.tap { |hash| hash.delete(:parent) } }

        it "fetches the parent from the backend" do
          expect_callback(:fetch_related_entity, "Parent", parent_guid).and_return(remote_parent)
          expect(Federation::Fetcher).not_to receive(:fetch_public)

          new_entity = Entities::SomeRelayable.from_hash(data, entity.send(:signature_order))

          expect(new_entity.parent).to eq(remote_parent)
        end

        it "fetches the parent from remote if not found on backend" do
          expect_callback(:fetch_related_entity, "Parent", parent_guid).and_return(nil, remote_parent)
          expect(Federation::Fetcher).to receive(:fetch_public).with(author, "Parent", parent_guid)

          new_entity = Entities::SomeRelayable.from_hash(data, entity.send(:signature_order))

          expect(new_entity.parent).to eq(remote_parent)
        end
      end
    end

    describe "#sender_valid?" do
      it "allows author if the parent is local" do
        entity = Entities::SomeRelayable.new(hash)

        expect(entity.sender_valid?(author)).to be_truthy
      end

      it "does not allow the author if the parent is not local" do
        entity = Entities::SomeRelayable.new(hash.merge(parent: remote_parent))

        expect(entity.sender_valid?(author)).to be_falsey
      end

      it "allows parent author" do
        entity = Entities::SomeRelayable.new(hash.merge(parent: remote_parent))

        expect(entity.sender_valid?(remote_parent.author)).to be_truthy
      end

      it "does not allow any random author" do
        entity = Entities::SomeRelayable.new(hash)
        invalid_author = Fabricate.sequence(:diaspora_id)

        expect(entity.sender_valid?(invalid_author)).to be_falsey
      end

      context "multi-layer relayable" do
        let(:intermediate_author) { Fabricate.sequence(:diaspora_id) }

        it "allows author if the root entity is local" do
          parent = Fabricate(:related_entity, author: intermediate_author, local: false, parent: local_parent)
          entity = Entities::SomeRelayable.new(hash.merge(parent: parent))

          expect(entity.sender_valid?(author)).to be_truthy
        end

        it "does not allow the author if the root entity is not local" do
          parent = Fabricate(:related_entity, author: intermediate_author, local: true, parent: remote_parent)
          entity = Entities::SomeRelayable.new(hash.merge(parent: parent))

          expect(entity.sender_valid?(author)).to be_falsey
        end

        it "allows root entity author" do
          parent = Fabricate(:related_entity, author: intermediate_author, local: false, parent: remote_parent)
          entity = Entities::SomeRelayable.new(hash.merge(parent: parent))

          expect(entity.sender_valid?(remote_parent.author)).to be_truthy
        end

        it "does not allow an intermediate parent author" do
          parent = Fabricate(:related_entity, author: intermediate_author, local: false, parent: remote_parent)
          entity = Entities::SomeRelayable.new(hash.merge(parent: parent))

          expect(entity.sender_valid?(intermediate_author)).to be_falsey
        end
      end
    end
  end
end
