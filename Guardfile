# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme

# Prevent informational messages from Guard
logger level: :warn

guard :rubocop, cli: '--format progress --format json --out tmp/rubocop.json ',
                all_on_start: true, all_after_pass: true do
  watch(/.+\.rb$/)
  watch(/Guardfile/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec --format progress --format json --out tmp/rspec.json',
              all_on_start: true, all_after_pass: true do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  dsl.watch_spec_files_for(dsl.ruby.lib_files)

  # Everything under lib/guard/boondoc is exercised through the plugin
  watch(%r{^lib/guard/boondoc/}) { 'spec' }
end

# The plugin itself, loaded from the local gemspec, last so it runs after the guards above
guard :boondoc
