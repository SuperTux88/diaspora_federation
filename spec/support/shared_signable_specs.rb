# frozen_string_literal: true

shared_examples "a signable" do
  let(:private_key) { OpenSSL::PKey::RSA.generate(1024) }
  let(:test_signature) { sign_with_key(private_key, test_string) }

  describe "#sign_with_key" do
    it "produces a correct signature" do
      signature = test_class.new({}).sign_with_key(private_key)
      expect(verify_signature(private_key.public_key, signature, test_string)).to be_truthy
    end
  end

  describe "#verify_signature" do
    it "doesn't raise if signature is correct" do
      expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

      expect {
        test_class.new(my_signature: test_signature).verify_signature("id@example.tld", :my_signature)
      }.not_to raise_error
    end

    it "raises PublicKeyNotFound when key isn't provided" do
      expect_callback(:fetch_public_key, "id@example.tld").and_return(nil)

      expect {
        test_class.new(my_signature: test_signature).verify_signature("id@example.tld", :my_signature)
      }.to raise_error(DiasporaFederation::Entities::Signable::PublicKeyNotFound)
    end

    it "raises SignatureVerificationFailed when signature isn't provided" do
      expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

      expect { test_class.new({}).verify_signature("id@example.tld", :my_signature) }.to raise_error(
        DiasporaFederation::Entities::Signable::SignatureVerificationFailed
      )
    end

    it "raises SignatureVerificationFailed when signature is wrong" do
      expect_callback(:fetch_public_key, "id@example.tld").and_return(private_key.public_key)

      expect {
        test_class.new(my_signature: "faked signature").verify_signature("id@example.tld", :my_signature)
      }.to raise_error(DiasporaFederation::Entities::Signable::SignatureVerificationFailed)
    end
  end
end
