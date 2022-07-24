# frozen_string_literal: true

module DiasporaFederation
  describe ReceiveController, type: :routing do
    routes { DiasporaFederation::Engine.routes }

    it "routes GET webfinger" do
      expect(get: "/.well-known/webfinger").to route_to(
        controller: "diaspora_federation/webfinger",
        action: "webfinger"
      )
    end
  end
end
