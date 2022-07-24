# frozen_string_literal: true

module DiasporaFederation
  describe HttpClient do
    describe ".get" do
      it "gets the url" do
        stub_request(:get, "http://www.example.com").to_return(body: "foobar", status: 200)

        response = HttpClient.get("http://www.example.com")
        expect(response.body).to eq("foobar")
      end

      it "follows redirects" do
        stub_request(:get, "http://www.example.com").to_return(
          status: 302,
          headers: {
            "Location" => "http://www.example.com/redirected"
          }
        )
        stub_request(:get, "http://www.example.com/redirected").to_return(body: "foobar", status: 200)

        response = HttpClient.get("http://www.example.com")
        expect(response.body).to eq("foobar")
      end

      it "follows redirects 4 times" do
        stub_request(:get, "http://www.example.com")
          .to_return(status: 302, headers: { "Location" => "http://www.example.com" })
          .times(4)
          .to_return(status: 200)

        HttpClient.get("http://www.example.com")
      end

      it "follows redirects not more than 4 times" do
        stub_request(:get, "http://www.example.com").to_return(
          status: 302,
          headers: {
            "Location" => "http://www.example.com"
          }
        )

        expect {
          HttpClient.get("http://www.example.com")
        }.to raise_error Faraday::FollowRedirects::RedirectLimitReached
      end

      it "uses the gem name as User-Agent" do
        stub_request(:get, "http://www.example.com").with(
          headers: {
            "User-Agent" => "DiasporaFederation/#{DiasporaFederation::VERSION}"
          }
        )

        HttpClient.get("http://www.example.com")
      end
    end

    describe ".connection" do
      it "returns a new connection every time" do
        expect(HttpClient.connection).to be_a Faraday::Connection
      end

      it "returns a new connection every time" do
        connection1 = HttpClient.connection
        expect(HttpClient.connection).to_not be(connection1)
      end
    end
  end
end
