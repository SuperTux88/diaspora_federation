# frozen_string_literal: true

require "prettier"
require "prettier/rake/task"

Prettier::Rake::Task.new { |t| t.source_files = "**/{*.rb,*.rake,*.md,*.yml,Gemfile}" }
