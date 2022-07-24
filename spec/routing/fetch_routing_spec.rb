# frozen_string_literal: true

module DiasporaFederation
  describe ReceiveController, type: :routing do
    routes { DiasporaFederation::Engine.routes }

    let(:guid) { "12345678901234567890abcdefgh" }

    it "routes post fetch" do
      expect(get: "/fetch/post/#{guid}").to route_to(
        controller: "diaspora_federation/fetch",
        action: "fetch",
        type: "post",
        guid: guid
      )
    end

    it "routes post fetch" do
      expect(get: "/fetch/status_message/#{guid}").to route_to(
        controller: "diaspora_federation/fetch",
        action: "fetch",
        type: "status_message",
        guid: guid
      )
    end

    it "routes post fetch with GUID with dots (hubzilla)" do
      guid = "1234567890abcd@hubzilla.example.org"
      expect(get: "/fetch/post/#{guid}").to route_to(
        controller: "diaspora_federation/fetch",
        action: "fetch",
        type: "post",
        guid: guid
      )
    end
  end
end
