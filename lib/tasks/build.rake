# frozen_string_literal: true

desc "Build gem into the pkg directory"
task build: :test do
  FileUtils.rm_rf("pkg")
  Dir["*.gemspec"].each { |gemspec| system "gem build #{gemspec}" }
  FileUtils.mkdir_p("pkg")
  FileUtils.mv(Dir["*.gem"], "pkg")

  Rake::Task["update_json_schemas"].invoke
end

desc "Update JSON schemas for github-pages"
task :update_json_schemas do
  git_clean = `git status --porcelain`.empty?
  sh "git stash" unless git_clean

  FileUtils.mkdir_p("docs/schemas")
  FileUtils.cp(Dir["lib/diaspora_federation/schemas/*.json"], "docs/schemas")

  sh "git add docs/schemas && git diff --staged --quiet || git commit -m 'Update JSON schemas for github-pages'"
  sh "git stash pop" unless git_clean
end

desc "Tags version, pushes to remote, and pushes gem"
task release: :build do
  sh "ls pkg/diaspora_federation-*-*.gem | xargs -n 1 gem push"
end
