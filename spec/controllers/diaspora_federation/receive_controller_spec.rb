# frozen_string_literal: true

module DiasporaFederation
  describe ReceiveController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "POST #public" do
      context "magic envelope" do
        before do
          Mime::Type.register("application/magic-envelope+xml", :magic_envelope)
          @request.env["CONTENT_TYPE"] = "application/magic-envelope+xml"
        end

        it "returns a 202 if queued correctly" do
          expect_callback(:queue_public_receive, "<me:env/>")

          post :public, body: +"<me:env/>"
          expect(response.code).to eq("202")
        end
      end
    end

    describe "POST #private" do
      context "encrypted magic envelope" do
        before do
          @request.env["CONTENT_TYPE"] = "application/json"
        end

        it "return a 404 if not queued successfully (unknown user guid)" do
          expect_callback(
            :queue_private_receive, "any-guid", "{\"aes_key\": \"key\", \"encrypted_magic_envelope\": \"env\"}"
          ).and_return(false)

          post :private,
               body: +"{\"aes_key\": \"key\", \"encrypted_magic_envelope\": \"env\"}",
               params: { guid: "any-guid" }
          expect(response.code).to eq("404")
        end

        it "returns a 202 if the callback returned true" do
          expect_callback(
            :queue_private_receive, "any-guid", "{\"aes_key\": \"key\", \"encrypted_magic_envelope\": \"env\"}"
          ).and_return(true)

          post :private,
               body: +"{\"aes_key\": \"key\", \"encrypted_magic_envelope\": \"env\"}",
               params: { guid: "any-guid" }
          expect(response.code).to eq("202")
        end
      end
    end
  end
end
