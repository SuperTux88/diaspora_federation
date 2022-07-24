# frozen_string_literal: true

module DiasporaFederation
  describe FetchController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    let(:guid) { "12345678901234567890" }
    let(:post) { Fabricate(:status_message_entity, guid: guid, author: alice.diaspora_id) }

    describe "GET #fetch" do
      it "returns the magic-envelope with the status message" do
        expect_callback(:fetch_public_entity, "StatusMessage", guid).and_return(post)
        expect_callback(:fetch_private_key, alice.diaspora_id).and_return(alice.private_key)

        get :fetch, params: { type: "status_message", guid: guid }

        expect_callback(:fetch_public_key, alice.diaspora_id).and_return(alice.public_key)

        magic_env_xml = Nokogiri.XML(response.body).root
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        entity = magic_env.payload

        expect(entity).to be_a(Entities::StatusMessage)
        expect(entity.guid).to eq(guid)
        expect(entity.author).to eq(alice.diaspora_id)
        expect(entity.text).to eq(post.text)
        expect(magic_env.sender).to eq(alice.diaspora_id)
      end

      it "works with type 'post'" do
        expect_callback(:fetch_public_entity, "Post", guid).and_return(post)
        expect_callback(:fetch_private_key, alice.diaspora_id).and_return(alice.private_key)

        get :fetch, params: { type: "post", guid: guid }

        expect_callback(:fetch_public_key, alice.diaspora_id).and_return(alice.public_key)

        magic_env_xml = Nokogiri.XML(response.body).root
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        entity = magic_env.payload

        expect(entity).to be_a(Entities::StatusMessage)
        expect(entity.guid).to eq(guid)
        expect(entity.author).to eq(alice.diaspora_id)
        expect(entity.text).to eq(post.text)
        expect(magic_env.sender).to eq(alice.diaspora_id)
      end

      it "redirects when the entity is from another pod" do
        expect_callback(:fetch_public_entity, "Post", guid).and_return(post)
        expect_callback(:fetch_private_key, alice.diaspora_id).and_return(nil)
        expect_callback(:fetch_person_url_to, alice.diaspora_id, "/fetch/post/#{guid}").and_return(
          "http://example.org/fetch/post/#{guid}"
        )

        get :fetch, params: { type: "post", guid: guid }

        expect(response).to be_redirect
        expect(response).to redirect_to "http://example.org/fetch/post/#{guid}"
      end

      it "404s when the post does not exist" do
        expect_callback(:fetch_public_entity, "Post", guid).and_return(nil)

        get :fetch, params: { type: "post", guid: guid }

        expect(response.status).to eq(404)
      end
    end
  end
end
