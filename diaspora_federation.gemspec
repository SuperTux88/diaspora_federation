# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff"]
  s.email       = ["benjamin@coding4.coffee"]
  s.homepage    = "https://github.com/diaspora/diaspora_federation"
  s.summary     = "diaspora* federation library"
  s.description = "This gem provides the functionality for de-/serialization and " \
                  "de-/encryption of Entities in the protocols used for communication " \
                  "among the various installations of Diaspora*"
  s.license     = "AGPL-3.0"
  s.metadata    = {
    "rubygems_mfa_required" => "true"
  }

  s.files = Dir["lib/**/*", "LICENSE", "README.md", "Changelog.md"] -
    Dir["lib/diaspora_federation/{engine,rails,schemas,test}.rb",
        "lib/diaspora_federation/schemas/*",
        "lib/diaspora_federation/test/*",
        "lib/tasks/*.rake"]

  s.required_ruby_version = ">= 3.0"

  s.add_dependency "base64"
  s.add_dependency "faraday", ">= 1.0", "< 3"
  s.add_dependency "faraday-follow_redirects", "~> 0.3"
  s.add_dependency "nokogiri", "~> 1.6", ">= 1.6.8"
  s.add_dependency "typhoeus", "~> 1.0"
  s.add_dependency "valid", "~> 1.0"
end
