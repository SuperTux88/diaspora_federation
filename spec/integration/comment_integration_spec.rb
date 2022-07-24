# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Relayable do
    let(:author_serialized_key) { <<~KEY }
      -----BEGIN RSA PRIVATE KEY-----
      MIICXgIBAAKBgQCxTbMp+M5sCUDVi9k1wMxedSwyLQcjBKQa0Qs6Qpnflz0k90hh
      btau0cy9jTK6S3CK2GhERXD6EecDlhZCbnSI9Bwmco5j6NbGPN5ai9tWgiBZzaEr
      yOVMQ4qCh1fKOMPX/LCvPzH+K7f8Q92zCuSvKSofg6zpg1zxGahpmxwqFQIDAQAB
      AoGBAKEXD2la/XF7FsTuwvLrsMNBgl40Ov+9/7u9oo3UZSmYp50mb0TXB4beZz7x
      Qt2wHRiJdnJRBUyvZ00C2EaTRJyFJA8p5J2qzHSjGpbPGyRCZUB6r6y+9vbM4ouj
      m5Vo47TQ7ob2D835BHJGR8dWM1zeAwWc6uLhNIu+/5lHQ90BAkEA6aVQFSXNYjmO
      fo6Oro+2nDaoa4jJ9qO1S23P2HF9N2f7CHDB4WKTdYnZpXs7ZPbnMEz62LeSC1MZ
      QOKGYkMuDQJBAMJEZWvfWtp+Zwm+IF1xGbNPzGrvHGJarE/QGUGYs7BR7tHFlepR
      aV3g56eGWfCWk8oWZRbjC2eQ2we96CU4cikCQQCqp3BCwgWthNSrY3yby6RZnSKO
      yK6bUx+MJHz3Xo1S9sPIenNiKBoEc9dgow3SxPQ/tzpRKGOnmd6MIeh9xQvRAkAV
      6WEHKco1msxEbQ15fKhJcVa9OPsanN+SoQY4P+EEojktr/uY0lXwIM4AN0ctu84v
      nRcJ3dILfGs4FFN630MBAkEA3zMOyNTeNdHrVhZc5b0qw2T6FUJGieDpOWLsff4w
      84yW10oS2CCmqEhbfh4Wu22amglytrATwD9hDzsTNAt8Mg==
      -----END RSA PRIVATE KEY-----
    KEY
    let(:author_key) { OpenSSL::PKey::RSA.new(author_serialized_key) }
    # -----BEGIN PUBLIC KEY-----
    # MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxTbMp+M5sCUDVi9k1wMxedSwy
    # LQcjBKQa0Qs6Qpnflz0k90hhbtau0cy9jTK6S3CK2GhERXD6EecDlhZCbnSI9Bwm
    # co5j6NbGPN5ai9tWgiBZzaEryOVMQ4qCh1fKOMPX/LCvPzH+K7f8Q92zCuSvKSof
    # g6zpg1zxGahpmxwqFQIDAQAB
    # -----END PUBLIC KEY-----

    let(:author) { "alice@pod-a.org" }
    let(:guid) { "e21589b0b41101333b870f77ba60fa73" }
    let(:parent_guid) { "9e269ae0b41201333b8c0f77ba60fa73" }
    let(:new_data) { "foobar" }
    let(:text) { "this is a very informative comment" }

    let(:parent) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:comment) do
      Entities::Comment.new(
        author: author, guid: guid, parent_guid: parent_guid, text: text, parent: parent, new_data: new_data
      )
    end

    let(:comment_xml_alice) { <<~XML }
      <comment>
        <author>alice@pod-a.org</author>
        <guid>e21589b0b41101333b870f77ba60fa73</guid>
        <parent_guid>9e269ae0b41201333b8c0f77ba60fa73</parent_guid>
        <text>this is a very informative comment</text>
        <author_signature>SQbLeqsEpFmSl74G1fFJXKQcsq6jp5B2ZjmfEOF/LbBccYP2oZEyEqOq18K3Fa71OYTp6Nddb38hCmHWWHvnGUltGfxKBnQ0WHafJUi40VM4VmeRoU8cac6m+1hslwe5SNmK6oh47EV3mRCXlgGGjLIrw7iEwjKL2g9x1gkNp2s=</author_signature>
      </comment>
    XML
    let(:comment_xml_alice_with_new_data) { <<~XML }
      <comment>
        <author>alice@pod-a.org</author>
        <guid>e21589b0b41101333b870f77ba60fa73</guid>
        <parent_guid>9e269ae0b41201333b8c0f77ba60fa73</parent_guid>
        <text>this is a very informative comment</text>
        <new_data>foobar</new_data>
        <author_signature>SFYXSvCX/DhTFiOUALp2Nf1kfNkGKXrnoBPikAyhaIogGydVBm+8tIlu1U/vsnpyKO3yfC3JReJ00/UBd4J16VO1IxStntq8NUqbSv4me5A/6kdK9Xg6eYbXrqQGm8fUQ5Xuh2UzeB71p7SVySXX3OZHVe0dvHCxH/lsfSDpEjc=</author_signature>
      </comment>
    XML

    let(:comment_xml_bob_legacy_order) { <<~XML }
      <comment>
        <guid>e21589b0b41101333b870f77ba60fa73</guid>
        <parent_guid>9e269ae0b41201333b8c0f77ba60fa73</parent_guid>
        <text>this is a very informative comment</text>
        <author>alice@pod-a.org</author>
        <author_signature>XU5X1uqTh8SY6JMG9uhEVR5Rg7FURV6lpRwl/HYOu6DJ3Hd9tpA2aSFFibUxxsMgJXKNrrc5SykrrEdTiQoEei+j0QqZf3B5R7r84qgK7M46KazwIpqRPwVl2MdA/0DdQyYJLA/oavNj1nwll9vtR87M7e/C94qG6P+iQTMBQzo=</author_signature>
      </comment>
    XML
    let(:comment_xml_bob) { <<~XML }
      <comment>
        <author>alice@pod-a.org</author>
        <guid>e21589b0b41101333b870f77ba60fa73</guid>
        <parent_guid>9e269ae0b41201333b8c0f77ba60fa73</parent_guid>
        <text>this is a very informative comment</text>
        <author_signature>SQbLeqsEpFmSl74G1fFJXKQcsq6jp5B2ZjmfEOF/LbBccYP2oZEyEqOq18K3Fa71OYTp6Nddb38hCmHWWHvnGUltGfxKBnQ0WHafJUi40VM4VmeRoU8cac6m+1hslwe5SNmK6oh47EV3mRCXlgGGjLIrw7iEwjKL2g9x1gkNp2s=</author_signature>
      </comment>
    XML
    let(:comment_xml_bob_with_new_data) { <<~XML }
      <comment>
        <author>alice@pod-a.org</author>
        <guid>e21589b0b41101333b870f77ba60fa73</guid>
        <parent_guid>9e269ae0b41201333b8c0f77ba60fa73</parent_guid>
        <text>this is a very informative comment</text>
        <new_data>foobar</new_data>
        <author_signature>SFYXSvCX/DhTFiOUALp2Nf1kfNkGKXrnoBPikAyhaIogGydVBm+8tIlu1U/vsnpyKO3yfC3JReJ00/UBd4J16VO1IxStntq8NUqbSv4me5A/6kdK9Xg6eYbXrqQGm8fUQ5Xuh2UzeB71p7SVySXX3OZHVe0dvHCxH/lsfSDpEjc=</author_signature>
      </comment>
    XML

    # this was used to create the XMLs above
    context "test-data creation" do
      it "creates comment xml" do
        expect_callback(:fetch_private_key, author).and_return(author_key)

        comment.to_xml
      end

      it "creates relayed comment xml" do
        expect_callback(:fetch_public_key, author).and_return(author_key.public_key)
        expect_callback(:fetch_related_entity, "Post", parent_guid).and_return(parent)

        xml = Nokogiri::XML(comment_xml_alice_with_new_data).root
        Entity.entity_class(xml.name).from_xml(xml).to_xml
      end
    end

    context "relaying on bobs pod" do
      before do
        expect_callback(:fetch_public_key, author).and_return(author_key.public_key)
        expect_callback(:fetch_related_entity, "Post", parent_guid).and_return(parent)
      end

      it "relays new order" do
        xml = Nokogiri::XML(comment_xml_alice).root
        entity = Entity.entity_class(xml.name).from_xml(xml)
        expect(entity.to_xml.to_xml).to eq(comment_xml_bob.strip)
      end

      it "relays new data" do
        xml = Nokogiri::XML(comment_xml_alice_with_new_data).root
        entity = Entity.entity_class(xml.name).from_xml(xml)
        expect(entity.to_xml.to_xml).to eq(comment_xml_bob_with_new_data.strip)
      end
    end

    context "parsing on every other pod" do
      let(:parent) { Fabricate(:related_entity, author: bob.diaspora_id, local: false) }

      before do
        expect_callback(:fetch_public_key, author).and_return(author_key.public_key)
        expect_callback(:fetch_related_entity, "Post", parent_guid).and_return(parent)
      end

      it "parses legacy order with new xml format" do
        xml = Nokogiri::XML(comment_xml_bob_legacy_order).root
        entity = Entity.entity_class(xml.name).from_xml(xml)

        expect(entity.author).to eq(author)
        expect(entity.text).to eq(text)
      end

      it "parses new xml format" do
        xml = Nokogiri::XML(comment_xml_bob).root
        entity = Entity.entity_class(xml.name).from_xml(xml)

        expect(entity.author).to eq(author)
        expect(entity.text).to eq(text)
      end

      it "parses new data with new xml format" do
        xml = Nokogiri::XML(comment_xml_bob_with_new_data).root
        entity = Entity.entity_class(xml.name).from_xml(xml)

        expect(entity.author).to eq(author)
        expect(entity.text).to eq(text)
        expect(entity.additional_data["new_data"]).to eq(new_data)
      end
    end
  end
end
