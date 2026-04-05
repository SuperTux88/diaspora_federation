# frozen_string_literal: true

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

begin
  require "rdoc/task"
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = "rdoc"
    rdoc.title    = "DiasporaFederation"
    rdoc.options << "--line-numbers"
    rdoc.rdoc_files.include("lib/**/*.rb")
  end
rescue LoadError
  # rdoc is not part of the default gems since Ruby 4.0 and is only
  # installed in the :development bundle group; gracefully skip the
  # task in CI where BUNDLE_WITHOUT=development is set.
end

if defined?(Rails)
  APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
  load "rails/tasks/engine.rake"
  load "rails/tasks/statistics.rake"

  Rails.application.load_tasks
else
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  FileList["lib/tasks/**/*.rake"].each {|task| load(task) }
end

Bundler::GemHelper.install_tasks name: "diaspora_federation"

desc "Run all tests"
task test: :spec
task default: :test
