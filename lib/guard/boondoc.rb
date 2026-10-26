# frozen_string_literal: true

require 'fileutils'
require 'guard/compat/plugin'
require 'boondoc'
require_relative 'boondoc/version'

module Guard
  # Regenerates boondoc documentation when a file boondoc reads changes.
  #
  # What to watch and where the docs go come from `.boondoc.yml` and
  # `.yardopts`, which are read again on every run. The only option is
  # `status_file`, a path the outcome of each run is written to: `ok`, or
  # `error` followed by boondoc's message.
  #
  # @example Guardfile
  #   guard :boondoc
  #
  # @example Guardfile, recording each run's outcome
  #   guard :boondoc, status_file: 'tmp/docs_status.txt'
  #
  # @example Guardfile, overriding what is watched
  #   guard :boondoc do
  #     watch(%r{^templates/})
  #   end
  class Boondoc < Plugin
    # Files whose change can alter how every other file is read.
    CONFIG_FILES = [::Boondoc::Config::FILE, '.yardopts'].freeze
    GLOB_FLAGS = File::FNM_PATHNAME | File::FNM_EXTGLOB

    # Watches every file, then narrows to the ones boondoc reads when they change,
    # since those are only known from the configuration. Watchers given in the
    # Guardfile replace that, and then decide on their own when to regenerate.
    def initialize(options = {})
      super
      @custom_watchers = !watchers.empty?
      self.watchers = [Guard::Watcher.new(/./)] unless @custom_watchers
    end

    # @return [void]
    def start
      generate
    end

    # @return [void]
    def reload
      generate
    end

    # @return [void]
    def run_all
      generate
    end

    # @param paths [Array<String>] files that changed, relative to the project
    # @return [void]
    def run_on_modifications(paths)
      paths = outside_output(paths)
      return if paths.empty?

      generate if @custom_watchers || relevant?(paths)
    end
    alias run_on_additions run_on_modifications
    alias run_on_removals run_on_modifications

    private

    def generate
      config = ::Boondoc::Config.load
      ::Boondoc::Generator.new(config).run
      remember(config)
      record('ok')
      Compat::UI.info('boondoc: docs regenerated')
    rescue ::Boondoc::Error => e
      record("error #{e.message}")
      Compat::UI.error("boondoc: #{e.message}")
      throw :task_has_failed
    end

    def record(status)
      path = options[:status_file] or return

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "#{status}\n")
    end

    def remember(config)
      @inputs = inputs(config)
    end

    def inputs(config)
      [config.source_files, config.extra_files, config.readme_file].flatten.compact
    end

    # A file is relevant if boondoc read it last run or would read it now, which
    # covers files added or removed since. Everything is relevant until a run has
    # succeeded, and when the configuration cannot be read.
    def relevant?(paths)
      return true unless @inputs

      config = ::Boondoc::Config.load
      known = @inputs | inputs(config)
      paths.any? { |path| CONFIG_FILES.include?(path) || known.include?(path) || asset?(config, path) }
    rescue ::Boondoc::Error
      true
    end

    def asset?(config, path)
      return false if in_output?(config, path)

      Array(config.assets).any? { |pattern| File.fnmatch?(pattern, path, GLOB_FLAGS) }
    end

    # Boondoc's own output must never trigger a run, whatever the watchers match.
    # When the configuration cannot be read, nothing is known to be output.
    def outside_output(paths)
      config = ::Boondoc::Config.load
      paths.reject { |path| in_output?(config, path) }
    rescue ::Boondoc::Error
      paths
    end

    def in_output?(config, path)
      output = config.output_dir.delete_prefix(File.join(config.root, ''))
      path == output || path.start_with?(File.join(output, ''))
    end
  end
end
