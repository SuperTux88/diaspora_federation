# frozen_string_literal: true

module DiasporaFederation
  describe Salmon::AES do
    let(:data) { "test data string" }

    describe ".generate_key_and_iv" do
      it "generates a random key and iv" do
        key_and_iv = Salmon::AES.generate_key_and_iv

        expect(key_and_iv[:key]).not_to be_empty
        expect(key_and_iv[:iv]).not_to be_empty
      end

      it "generates a different key and iv every time" do
        key_and_iv = Salmon::AES.generate_key_and_iv
        key_and_iv2 = Salmon::AES.generate_key_and_iv

        expect(key_and_iv[:key]).not_to eq(key_and_iv2[:key])
        expect(key_and_iv[:iv]).not_to eq(key_and_iv2[:iv])
      end
    end

    describe ".encrypt" do
      let(:key_and_iv) { Salmon::AES.generate_key_and_iv }

      it "encrypts the data" do
        ciphertext = Salmon::AES.encrypt(data, key_and_iv[:key], key_and_iv[:iv])

        expect(Base64.decode64(ciphertext)).not_to eq(data)
      end

      it "raises an error when the data is missing or the wrong type" do
        [nil, 1234, true, :symbol].each do |val|
          expect { Salmon::AES.encrypt(val, key_and_iv[:key], key_and_iv[:iv]) }.to raise_error ArgumentError
        end
      end
    end

    describe ".decrypt" do
      it "decrypts what it has encrypted" do
        key = Salmon::AES.generate_key_and_iv
        ciphertext = Salmon::AES.encrypt(data, key[:key], key[:iv])

        decrypted_data = Salmon::AES.decrypt(ciphertext, key[:key], key[:iv])

        expect(decrypted_data).to eq(data)
      end

      it "raises an error when the params are missing or the wrong type" do
        [nil, 1234, true, :symbol].each do |val|
          expect { Salmon::AES.decrypt(val, val, val) }.to raise_error ArgumentError
        end
      end
    end
  end
end
