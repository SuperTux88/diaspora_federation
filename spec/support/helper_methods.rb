# frozen_string_literal: true

# default users
def alice
  @alice ||= Person.find_by(diaspora_id: "alice@localhost:3000")
end

def bob
  @bob ||= Person.find_by(diaspora_id: "bob@localhost:3000")
end

# callback expectation helper
def expect_callback(*opts)
  expect(DiasporaFederation.callbacks).to receive(:trigger).with(*opts)
end

# signature methods
def add_signatures(hash, klass = described_class)
  properties = klass.new(hash).send(:xml_elements)
  hash[:author_signature] = properties[:author_signature]
end

def sign_with_key(privkey, signature_data)
  Base64.strict_encode64(privkey.sign(OpenSSL::Digest.new("SHA256"), signature_data))
end

def verify_signature(pubkey, signature, signed_string)
  pubkey.verify(OpenSSL::Digest.new("SHA256"), Base64.decode64(signature), signed_string)
end

# time helper
def change_time(time, options = {})
  new_hour  = options.fetch(:hour, time.hour)
  new_min   = options.fetch(:min, options[:hour] ? 0 : time.min)
  new_sec   = options.fetch(:sec, options[:hour] || options[:min] ? 0 : time.sec)

  ::Time.utc(time.year, time.month, time.day, new_hour, new_min, new_sec)
end

# indent helper
def indent(string, amount)
  string.gsub(/^/, " " * amount)
end
