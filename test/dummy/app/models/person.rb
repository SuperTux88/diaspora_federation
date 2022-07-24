# frozen_string_literal: true

class Person
  attr_accessor :diaspora_id, :url, :guid, :serialized_public_key, :serialized_private_key

  def initialize
    @guid = UUID.generate(:compact)
  end

  def private_key; OpenSSL::PKey::RSA.new(serialized_private_key) end
  def public_key;  OpenSSL::PKey::RSA.new(serialized_public_key) end

  def alias_url;     "#{url}people/#{guid}" end
  def hcard_url;     "#{url}hcard/users/#{guid}" end
  def profile_url;   "#{url}u/#{nickname}" end
  def atom_url;      "#{url}public/#{nickname}.atom" end
  def salmon_url;    "#{url}receive/users/#{guid}" end
  def subscribe_url; "#{url}people?q={uri}" end

  def nickname; diaspora_id.split("@")[0] end

  def photo_default_url; "#{url}assets/user/default.png" end

  def searchable; true end
  def full_name;  "Dummy User" end
  def first_name; "Dummy" end
  def last_name;  "User" end

  def save!
    Person.database[:diaspora_id][diaspora_id] = self
    Person.database[:guid][guid] = self
  end

  class << self
    attr_writer :init_database

    def find_by(opts)
      return database[:diaspora_id][opts[:diaspora_id]] if opts[:diaspora_id]

      database[:guid][opts[:guid]]
    end

    def database
      @database ||= @init_database || { diaspora_id: {}, guid: {} }
    end

    def reset_database
      @database = nil
    end
  end
end
