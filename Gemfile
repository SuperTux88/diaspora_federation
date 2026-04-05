# frozen_string_literal: true

source "https://rubygems.org"

# Declare your gem's dependencies in diaspora_federation.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec name: "diaspora_federation"

Dir["diaspora_federation-*.gemspec"].each do |gemspec|
  plugin = gemspec.scan(/diaspora_federation-(.*)\.gemspec/).flatten.first
  unless ENV["RAILS_VERSION"] == "none" && plugin == "rails"
    gemspec(name: "diaspora_federation-#{plugin}", development_group: plugin)
  end
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development do
  # code style
  gem "pronto",         "0.11.5",  require: false
  gem "pronto-rubocop", "0.11.6",  require: false
  gem "rubocop",        "1.86.0",  require: false
  gem "rubocop-rails",  "2.34.3",  require: false
  gem "rubocop-rake",   "0.7.1",   require: false

  # debugging
  gem "pry"
  gem "pry-byebug"

  # documentation
  gem "yard", require: false

  # rails needs this for development
  gem "listen"
end

group :test do
  # rspec formatter
  gem "fuubar", "2.5.1",    require: false
  gem "nyan-cat-formatter", require: false

  # test coverage
  gem "simplecov",                 "0.22.0",   require: false
  gem "simplecov-rcov",            "0.3.1",    require: false

  # test helpers
  gem "json-schema",               "~> 6.0"
  gem "rspec-collection_matchers", "~> 1.2.0"
  gem "rspec-json_expectations",   "~> 2.1"
  gem "webmock",                   "~> 3.0"
end

group :development, :test do
  gem "rake"

  # unit tests
  gem "rspec", "~> 3.13.0"

  unless ENV["RAILS_VERSION"] == "none"
    # rspec-rails 7.x requires Rails >= 7.0; use 6.x for Rails 6.1
    if ENV["RAILS_VERSION"]&.start_with?("6.")
      gem "rspec-rails", "~> 6.1"
    else
      gem "rspec-rails", "~> 7.1"
    end

    # The default rails version needs to be kept up to date also in:
    # - test/dummy/config/application.rb (config.load_defaults)
    # - .github/workflows/ci.yml ('Delete Gemfile.lock' step)
    gem "actionpack", "~> #{ENV['RAILS_VERSION'] || '8.1'}.0"
  end
end
