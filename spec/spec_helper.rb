# frozen_string_literal: true

unless ENV["NO_COVERAGE"] == "true"
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::RcovFormatter]
  SimpleCov.start do
    add_filter "lib/diaspora_federation/logging.rb"
    add_filter "spec"
    add_filter "test"
  end
end

dummy_app_path = File.join(File.dirname(__FILE__), "..", "test", "dummy")

begin
  require "rails" # try to load rails
rescue LoadError
  Dir["#{File.join(dummy_app_path, "app", "models")}/*.rb"].sort.each { |f| require f }
  require File.join(dummy_app_path, "config", "initializers", "diaspora_federation")
else
  ENV["RAILS_ENV"] ||= "test"
  require File.join(dummy_app_path, "config", "environment")

  require "rspec/rails"
end

# test helpers
require "rspec/collection_matchers"
require "rspec/json_expectations"
require "webmock/rspec"

# load factories
require "factories"

# load test entities
require "entities"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/rspec-persistence.txt"

  config.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end

  if defined?(::Rails)
    config.before(:each, type: :controller) { ActionController::Base.allow_forgery_protection = true }
  else
    config.exclude_pattern = "**/controllers/**/*_spec.rb, **/routing/**/*_spec.rb"
    config.filter_run_excluding rails: true
  end

  # whitelist codeclimate.com so test coverage can be reported
  config.after(:suite) { WebMock.disable_net_connect!(allow: "codeclimate.com") }

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
