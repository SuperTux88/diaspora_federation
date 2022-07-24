# frozen_string_literal: true

module DiasporaFederation
  describe Federation::Fetcher do
    let(:post) { Fabricate(:status_message_entity, public: true) }
    let(:post_magic_env) { Salmon::MagicEnvelope.new(post, post.author).envelop(alice.private_key).to_xml }

    describe ".fetch_public" do
      it "fetches a public post with symbol as type param" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ) do |magic_env|
          expect(magic_env.payload.guid).to eq(post.guid)
          expect(magic_env.payload.author).to eq(post.author)
          expect(magic_env.payload.text).to eq(post.text)
          expect(magic_env.payload.public).to eq(post.public)
          receiver
        end
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "fetches a public post with class name as type param" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ) do |magic_env|
          expect(magic_env.payload.guid).to eq(post.guid)
          expect(magic_env.payload.author).to eq(post.author)
          expect(magic_env.payload.text).to eq(post.text)
          expect(magic_env.payload.public).to eq(post.public)
          receiver
        end
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, "Post", post.guid)
      end

      it "follows redirects" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 302, headers: { "Location" => "https://example.com/fetch/post/#{post.guid}" })
        stub_request(:get, "https://example.com/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ).and_return(receiver)
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "raises NotFetchable if post not found (private)" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 404)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end

      it "raises NotFetchable if connection refused" do
        expect(HttpClient).to receive(:get).with(
          "https://example.org/fetch/post/#{post.guid}"
        ).and_raise(Faraday::ConnectionFailed, "Couldn't connect to server")

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end

      it "detects a loop and breaks it" do
        guid1 = Fabricate.sequence(:guid)
        guid2 = Fabricate.sequence(:guid)
        text1 = "Look at diaspora://#{alice.diaspora_id}/post/#{guid2}"
        text2 = "LOL a loop at diaspora://#{alice.diaspora_id}/post/#{guid1}"
        post1 = Fabricate(:status_message_entity, public: true, guid: guid1, text: text1, author: alice.diaspora_id)
        post2 = Fabricate(:status_message_entity, public: true, guid: guid2, text: text2, author: alice.diaspora_id)

        [post1, post2].each do |post|
          post_magic_env = Salmon::MagicEnvelope.new(post, post.author).envelop(alice.private_key).to_xml

          stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
            .to_return(status: 200, body: post_magic_env)

          expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
            .and_return("https://example.org/fetch/post/#{post.guid}")
          expect_callback(:fetch_related_entity, "Post", post.guid).and_return(nil)
          expect_callback(:receive_entity, kind_of(DiasporaFederation::Entities::StatusMessage), post.author, nil)
        end

        expect_callback(:fetch_public_key, alice.diaspora_id).twice.and_return(alice.public_key)

        Federation::Fetcher.fetch_public(post1.author, :post, post1.guid)
      end

      it "allows to fetch the same entity in two different threads" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: lambda { |_|
            sleep 0.1
            post_magic_env
          })

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .twice.and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).twice.and_return(alice.public_key)
        expect_callback(:receive_entity, kind_of(DiasporaFederation::Entities::StatusMessage), post.author, nil).twice

        threads = Array.new(2).map do
          Thread.new { Federation::Fetcher.fetch_public(post.author, :post, post.guid) }
        end
        threads.each(&:join)
      end
    end
  end
end
