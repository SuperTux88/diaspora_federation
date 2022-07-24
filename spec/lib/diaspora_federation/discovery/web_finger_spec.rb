# frozen_string_literal: true

module DiasporaFederation
  describe Discovery::WebFinger do
    let(:person) { Fabricate(:person) }
    let(:acct) { "acct:#{person.diaspora_id}" }
    let(:public_key_base64) { Base64.strict_encode64(person.serialized_public_key) }

    let(:data) {
      {
        acct_uri: acct,
        hcard_url: person.hcard_url,
        seed_url: person.url,
        profile_url: person.profile_url,
        atom_url: person.atom_url,
        salmon_url: person.salmon_url,
        subscribe_url: person.subscribe_url
      }
    }

    let(:json) { <<~JSON }
      {
        "subject": "#{acct}",
        "aliases": [
          "#{person.alias_url}"
        ],
        "links": [
          {
            "rel": "http://microformats.org/profile/hcard",
            "type": "text/html",
            "href": "#{person.hcard_url}"
          },
          {
            "rel": "http://joindiaspora.com/seed_location",
            "type": "text/html",
            "href": "#{person.url}"
          },
          {
            "rel": "http://webfinger.net/rel/profile-page",
            "type": "text/html",
            "href": "#{person.profile_url}"
          },
          {
            "rel": "http://schemas.google.com/g/2010#updates-from",
            "type": "application/atom+xml",
            "href": "#{person.atom_url}"
          },
          {
            "rel": "salmon",
            "href": "#{person.salmon_url}"
          },
          {
            "rel": "http://ostatus.org/schema/1.0/subscribe",
            "template": "#{person.url}people?q={uri}"
          }
        ]
      }
    JSON

    let(:minimal_json) { <<~JSON }
      {
        "subject": "#{acct}",
        "links": [
          {
            "rel": "http://microformats.org/profile/hcard",
            "type": "text/html",
            "href": "#{person.hcard_url}"
          },
          {
            "rel": "http://joindiaspora.com/seed_location",
            "type": "text/html",
            "href": "#{person.url}"
          }
        ]
      }
    JSON

    let(:string) { "WebFinger:#{data[:acct_uri]}" }

    it_behaves_like "an Entity subclass"

    context "when generating" do
      let(:minimal_data) { {acct_uri: acct, hcard_url: person.hcard_url, seed_url: person.url} }
      let(:additional_data) {
        {
          aliases: [person.alias_url, person.profile_url],
          properties: {"http://webfinger.example/ns/name" => "Bob Smith"},
          links: [
            {rel: "http://portablecontacts.net/spec/1.0", href: "https://pod.example.tld/poco/trouble"},
            {
              rel: "http://webfinger.net/rel/avatar",
              type: "image/jpeg",
              href: "http://localhost:3000/assets/user/default.png"
            },
            {rel: "http://openid.net/specs/connect/1.0/issuer", href: "https://pod.example.tld/"}
          ]
        }
      }

      it "creates a nice JSON document" do
        wf = Discovery::WebFinger.new(data, aliases: [person.alias_url])
        expect(JSON.pretty_generate(wf.to_json)).to eq(json.strip)
      end

      it "creates minimal JSON document" do
        wf = Discovery::WebFinger.new(minimal_data)
        expect(JSON.pretty_generate(wf.to_json)).to eq(minimal_json.strip)
      end

      it "creates JSON document with additional data" do
        json_with_additional_data = <<~JSON
          {
            "subject": "#{acct}",
            "aliases": [
              "#{person.alias_url}",
              "#{person.profile_url}"
            ],
            "properties": {
              "http://webfinger.example/ns/name": "Bob Smith"
            },
            "links": [
              {
                "rel": "http://microformats.org/profile/hcard",
                "type": "text/html",
                "href": "#{person.hcard_url}"
              },
              {
                "rel": "http://joindiaspora.com/seed_location",
                "type": "text/html",
                "href": "#{person.url}"
              },
              {
                "rel": "http://portablecontacts.net/spec/1.0",
                "href": "https://pod.example.tld/poco/trouble"
              },
              {
                "rel": "http://webfinger.net/rel/avatar",
                "type": "image/jpeg",
                "href": "http://localhost:3000/assets/user/default.png"
              },
              {
                "rel": "http://openid.net/specs/connect/1.0/issuer",
                "href": "https://pod.example.tld/"
              }
            ]
          }
        JSON

        wf = Discovery::WebFinger.new(minimal_data, additional_data)
        expect(JSON.pretty_generate(wf.to_json)).to eq(json_with_additional_data.strip)
      end

      it "does not support XML anymore" do
        expect { Discovery::WebFinger.new(minimal_data).to_xml }
          .to raise_error "Generating WebFinger to XML is not supported anymore, use 'to_json' instead."
      end
    end

    context "when parsing" do
      it "reads its own json output" do
        wf = Discovery::WebFinger.from_json(json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)
        expect(wf.subscribe_url).to eq(person.subscribe_url)
      end

      it "reads minimal json" do
        wf = Discovery::WebFinger.from_json(minimal_json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
      end

      it "is frozen after parsing" do
        wf = Discovery::WebFinger.from_json(json)
        expect(wf).to be_frozen
      end

      it "reads friendica JSON" do
        friendica_hcard_url = "#{person.url}hcard/#{person.nickname}"
        friendica_profile_url = "#{person.url}profile/#{person.nickname}"
        friendica_atom_url = "#{person.url}dfrn_poll/#{person.nickname}"
        friendica_salmon_url = "#{person.url}salmon/#{person.nickname}"
        friendica_subscribe_url = "#{person.url}follow?url={uri}"

        friendica_json = <<~JSON
          {
            "subject": "#{acct}",
            "aliases": [
              "#{person.url}~#{person.nickname}",
              "#{friendica_profile_url}"
            ],
            "links": [
              {
                "rel": "http://purl.org/macgirvin/dfrn/1.0",
                "href": "#{person.url}profile/#{person.nickname}"
              },
              {
                "rel": "http://schemas.google.com/g/2010#updates-from",
                "type": "application/atom+xml",
                "href": "#{friendica_atom_url}"
              },
              {
                "rel": "http://webfinger.net/rel/profile-page",
                "type": "text/html",
                "href": "#{friendica_profile_url}"
              },
              {
                "rel": "self",
                "type": "application/activity+json",
                "href": "#{friendica_profile_url}"
              },
              {
                "rel": "http://microformats.org/profile/hcard",
                "type": "text/html",
                "href": "#{friendica_hcard_url}"
              },
              {
                "rel": "http://portablecontacts.net/spec/1.0",
                "href": "#{person.url}poco/#{person.nickname}"
              },
              {
                "rel": "http://webfinger.net/rel/avatar",
                "type": "image/png",
                "href": "#{person.url}photo/profile/#{person.nickname}.png"
              },
              {
                "rel": "http://joindiaspora.com/seed_location",
                "type": "text/html",
                "href": "#{person.url}"
              },
              {
                "rel": "salmon",
                "href": "#{friendica_salmon_url}"
              },
              {
                "rel": "http://salmon-protocol.org/ns/salmon-replies",
                "href": "#{friendica_salmon_url}"
              },
              {
                "rel": "http://salmon-protocol.org/ns/salmon-mention",
                "href": "#{friendica_salmon_url}/mention"
              },
              {
                "rel": "http://ostatus.org/schema/1.0/subscribe",
                "template": "#{person.url}follow?url={uri}"
              },
              {
                "rel": "magic-public-key",
                "href": "data:application/magic-public-key,RSA.abcdef1234567890"
              },
              {
                "rel": "http://purl.org/openwebauth/v1",
                "type": "application/x-zot+json",
                "href": "#{person.url}owa"
              }
            ]
          }
        JSON

        wf = Discovery::WebFinger.from_json(friendica_json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(friendica_hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(friendica_profile_url)
        expect(wf.atom_url).to eq(friendica_atom_url)
        expect(wf.salmon_url).to eq(friendica_salmon_url)
        expect(wf.subscribe_url).to eq(friendica_subscribe_url)
      end

      it "reads hubzilla JSON" do
        hubzilla_hcard_url = "#{person.url}hcard/#{person.nickname}"
        hubzilla_profile_url = "#{person.url}profile/#{person.nickname}"
        hubzilla_atom_url = "#{person.url}ofeed/#{person.nickname}"
        hubzilla_subscribe_url = "#{person.url}follow?f=&url={uri}"

        hubzilla_json = <<~JSON
          {
            "subject": "#{acct}",
            "aliases": [
              "#{person.url}channel/#{person.nickname}",
              "#{person.url}~#{person.nickname}",
              "#{person.url}@#{person.nickname}"
            ],
            "properties": {
              "http://webfinger.net/ns/name": "#{person.full_name}",
              "http://xmlns.com/foaf/0.1/name": "#{person.full_name}",
              "https://w3id.org/security/v1#publicKeyPem": #{person.serialized_public_key.dump},
              "http://purl.org/zot/federation": "zot6,zot,activitypub,diaspora"
            },
            "links": [
              {
                "rel": "http://webfinger.net/rel/avatar",
                "type": "image/jpeg",
                "href": "#{person.url}photo/profile/l/2"
              },
              {
                "rel": "http://microformats.org/profile/hcard",
                "type": "text/html",
                "href": "#{hubzilla_hcard_url}"
              },
              {
                "rel": "http://openid.net/specs/connect/1.0/issuer",
                "href": "#{person.url}"
              },
              {
                "rel": "http://webfinger.net/rel/profile-page",
                "href": "#{hubzilla_profile_url}"
              },
              {
                "rel": "http://schemas.google.com/g/2010#updates-from",
                "type": "application/atom+xml",
                "href": "#{hubzilla_atom_url}"
              },
              {
                "rel": "http://webfinger.net/rel/blog",
                "href": "#{person.url}channel/#{person.nickname}"
              },
              {
                "rel": "http://ostatus.org/schema/1.0/subscribe",
                "template": "#{hubzilla_subscribe_url}"
              },
              {
                "rel": "http://purl.org/zot/protocol/6.0",
                "type": "application/x-zot+json",
                "href": "#{person.url}channel/#{person.nickname}"
              },
              {
                "rel": "http://purl.org/zot/protocol",
                "href": "#{person.url}.well-known/zot-info?address=#{person.nickname}@#{person.diaspora_id.split('@')[1]}"
              },
              {
                "rel": "http://purl.org/openwebauth/v1",
                "type": "application/x-zot+json",
                "href": "#{person.url}owa"
              },
              {
                "rel": "magic-public-key",
                "href": "data:application/magic-public-key,RSA.abcdef1234567890"
              },
              {
                "rel": "self",
                "type": "application/ld+json; profile=\\\"https://www.w3.org/ns/activitystreams\\\"",
                "href": "#{person.url}channel/#{person.nickname}"
              },
              {
                "rel": "self",
                "type": "application/activity+json",
                "href": "#{person.url}channel/#{person.nickname}"
              },
              {
                "rel": "http://joindiaspora.com/seed_location",
                "type": "text/html",
                "href": "#{person.url}"
              },
              {
                "rel": "salmon",
                "href": "#{person.salmon_url}"
              }
            ]
          }
        JSON

        wf = Discovery::WebFinger.from_json(hubzilla_json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(hubzilla_hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(hubzilla_profile_url)
        expect(wf.atom_url).to eq(hubzilla_atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)
        expect(wf.subscribe_url).to eq(hubzilla_subscribe_url)
      end

      it "fails if the document is empty" do
        invalid_json = <<~JSON
          {}
        JSON
        expect { Discovery::WebFinger.from_json(invalid_json) }.to raise_error Discovery::InvalidData
      end

      it "fails if the document is not JSON" do
        expect { Discovery::WebFinger.from_json("") }.to raise_error Discovery::InvalidDocument
      end

      it "does not support XML anymore" do
        expect { Discovery::WebFinger.from_xml("") }
          .to raise_error "Parsing WebFinger as XML is not supported anymore, use 'from_json' instead."
      end
    end
  end
end
