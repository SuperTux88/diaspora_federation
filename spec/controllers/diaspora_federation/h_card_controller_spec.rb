# frozen_string_literal: true

module DiasporaFederation
  describe HCardController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "GET #hcard" do
      it "succeeds when the person exists" do
        get :hcard, params: { guid: alice.guid }
        expect(response).to be_successful
      end

      it "contains the guid" do
        get :hcard, params: { guid: alice.guid }
        expect(response.body).to include "<span class=\"uid\">#{alice.guid}</span>"
      end

      it "contains the username" do
        get :hcard, params: { guid: alice.guid }
        expect(response.body).to include "<span class=\"nickname\">alice</span>"
      end

      it "404s when the person does not exist" do
        get :hcard, params: { guid: "unknown_guid" }
        expect(response).to be_not_found
      end

      it "calls the fetch_person_for_hcard callback" do
        expect_callback(:fetch_person_for_hcard, alice.guid).and_call_original

        get :hcard, params: { guid: alice.guid }
      end
    end
  end
end
