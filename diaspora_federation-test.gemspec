# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "diaspora_federation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaspora_federation-test"
  s.version     = DiasporaFederation::VERSION
  s.authors     = ["Benjamin Neff"]
  s.email       = ["benjamin@coding4.coffee"]
  s.homepage    = "https://github.com/diaspora/diaspora_federation"
  s.summary     = "diaspora* federation test utils"
  s.description = "This gem provides some supplimentary code (factory definitions), that" \
                  "helps to build tests for users of the diaspora_federation gem."
  s.license     = "AGPL-3.0"
  s.metadata    = {
    "rubygems_mfa_required" => "true"
  }

  s.files = Dir["lib/diaspora_federation/test.rb", "lib/diaspora_federation/test/*"]

  s.required_ruby_version = ">= 3.0"

  s.add_dependency "diaspora_federation", DiasporaFederation::VERSION
  s.add_dependency "fabrication", "~> 2.29"
  s.add_dependency "uuid", "~> 2.3", ">= 2.3.8"
end
