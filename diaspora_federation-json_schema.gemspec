# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation-json_schema"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff", "cmrd Senya"]
  s.email       = ["benjamin@coding4.coffee", "senya@riseup.net"]
  s.homepage    = "https://github.com/diaspora/diaspora_federation"
  s.summary     = "diaspora* federation json schemas"
  s.description = "This gem provides JSON schemas (currently one schema) for " \
                  "validating JSON serialized federation objects."
  s.license     = "AGPL-3.0"
  s.metadata    = {
    "rubygems_mfa_required" => "true"
  }

  s.files = Dir["lib/diaspora_federation/schemas.rb", "lib/diaspora_federation/schemas/*.json"]

  s.required_ruby_version = ">= 3.0"
end
