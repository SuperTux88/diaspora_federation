# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Reshare do
    let(:root) { Fabricate(:post, author: bob) }
    let(:data) { Fabricate.attributes_for(:reshare_entity, root_guid: root.guid, root_author: bob.diaspora_id) }

    let(:xml) { <<~XML }
      <reshare>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <created_at>#{data[:created_at].utc.iso8601}</created_at>
        <root_author>#{data[:root_author]}</root_author>
        <root_guid>#{data[:root_guid]}</root_guid>
      </reshare>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "reshare",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "created_at": "#{data[:created_at].utc.iso8601}",
          "root_author": "#{data[:root_author]}",
          "root_guid": "#{data[:root_guid]}"
        }
      }
    JSON

    let(:string) { "Reshare:#{data[:guid]}:#{data[:root_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "parse xml" do
      describe "#validate_root" do
        it "fetches the root post if it is not available already" do
          root = Fabricate(:related_entity, author: bob.diaspora_id)
          expect_callback(:fetch_related_entity, "Post", data[:root_guid]).and_return(nil, root)
          expect(Federation::Fetcher).to receive(:fetch_public).with(data[:root_author], "Post", data[:root_guid])

          Entities::Reshare.from_xml(Nokogiri.XML(xml).root)
        end

        it "validates the author of the root post" do
          fake_root = Fabricate(:related_entity, author: alice.diaspora_id)
          expect_callback(:fetch_related_entity, "Post", data[:root_guid]).and_return(fake_root)

          expect { Entities::Reshare.from_xml(Nokogiri.XML(xml).root) }.to raise_error Entity::ValidationError
        end

        it "validates a reshare with no root" do
          data[:root_author] = nil
          data[:root_guid] = nil

          reshare = Entities::Reshare.from_xml(Nokogiri.XML(xml).root)
          expect(reshare.root_author).to be_nil
          expect(reshare.root_guid).to be_nil
        end

        it "disallows root_author without root_guid" do
          data[:root_guid] = nil

          expect { Entities::Reshare.from_xml(Nokogiri.XML(xml).root) }.to raise_error Entity::ValidationError
        end

        it "disallows root_guid without root_author" do
          data[:root_author] = nil

          expect { Entities::Reshare.from_xml(Nokogiri.XML(xml).root) }.to raise_error Entity::ValidationError
        end
      end
    end
  end
end
