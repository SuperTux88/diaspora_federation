# frozen_string_literal: true

module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "GET #webfinger" do
      it "uses the JRD format as default" do
        get :webfinger, params: { resource: alice.diaspora_id }
        expect(response).to be_successful
        expect(response.header["Content-Type"]).to include "application/jrd+json"
      end

      it "succeeds when the person exists" do
        get :webfinger, format: :json, params: { resource: alice.diaspora_id }
        expect(response).to be_successful
      end

      it "succeeds with 'acct:' in the query when the person exists" do
        get :webfinger, format: :json, params: { resource: "acct:#{alice.diaspora_id}" }
        expect(response).to be_successful
      end

      it "contains the diaspora* ID" do
        get :webfinger, format: :json, params: { resource: "acct:#{alice.diaspora_id}" }
        expect(response.body).to include "\"subject\": \"acct:alice@localhost:3000\""
      end

      it "returns a application/jrd+json" do
        get :webfinger, format: :json, params: { resource: "acct:#{alice.diaspora_id}" }
        expect(response.header["Content-Type"]).to include "application/jrd+json"
      end

      it "adds a Access-Control-Allow-Origin header" do
        get :webfinger, format: :json, params: { resource: "acct:#{alice.diaspora_id}" }
        expect(response.header["Access-Control-Allow-Origin"]).to eq("*")
      end

      it "404s when the person does not exist" do
        get :webfinger, format: :json, params: { resource: "me@mydiaspora.pod.com" }
        expect(response).to be_not_found
      end

      it "raises when the resource parameter is missing" do
        expect { get :webfinger, format: :json }.to raise_error(
          ActionController::ParameterMissing,
          /param is missing or the value is empty: resource/
        )
      end

      it "calls the fetch_person_for_webfinger callback" do
        expect_callback(:fetch_person_for_webfinger, "alice@localhost:3000").and_call_original

        get :webfinger, format: :json, params: { resource: "acct:alice@localhost:3000" }
      end
    end
  end
end
