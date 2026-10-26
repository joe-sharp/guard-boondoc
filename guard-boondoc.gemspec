# frozen_string_literal: true

require_relative 'lib/guard/boondoc/version'

Gem::Specification.new do |spec|
  spec.name = 'guard-boondoc'
  spec.version = Guard::BoondocVersion::VERSION
  spec.authors = ['Joe Sharp']
  spec.email = ['joesharp13@gmail.com']

  spec.summary = 'Guard plugin that regenerates your boondoc docs when their sources change'
  spec.description = 'guard-boondoc watches the files boondoc reads, as set in .boondoc.yml and .yardopts, ' \
                     'and regenerates your markdown documentation when one of them changes.'
  spec.homepage = 'https://github.com/joe-sharp/guard-boondoc'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{Guard::BoondocVersion::VERSION}"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select { |f| f.start_with?('lib/', 'CHANGELOG.md', 'LICENSE', 'README.md') }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'boondoc'
  spec.add_dependency 'guard', '~> 2.20'
  spec.add_dependency 'guard-compat', '~> 1.2'
end
