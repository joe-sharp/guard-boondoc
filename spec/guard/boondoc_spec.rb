# frozen_string_literal: true

RSpec.describe(Guard::Boondoc) do
  subject(:plugin) { described_class.new }

  let(:project) { Dir.mktmpdir }

  before do
    FileUtils.mkdir_p(File.join(project, "lib"))
    File.write(File.join(project, "lib", "widget.rb"), "# A widget.\nclass Widget; end\n")
    File.write(File.join(project, "README.md"), "# Widgets\n")
    groups = instance_double(Guard::Internals::Groups, add: nil)
    allow(Guard).to receive(:state).and_return(
      instance_double(Guard::Internals::State, session: instance_double(Guard::Internals::Session, groups: groups))
    )
    allow(Guard::Compat::UI).to receive(:info)
    allow(Guard::Compat::UI).to receive(:error)
    allow(Boondoc::Reporter).to(receive(:new).and_wrap_original { |m, **opts| m.call(**opts, io: StringIO.new) })
  end

  around do |example|
    Dir.chdir(project) { example.run }
  ensure
    FileUtils.remove_entry(project)
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  it "watches every file" do
    expect(Guard::Watcher.match_files(plugin, %w[a.rb docs/b.md .yardopts])).to eq(%w[a.rb docs/b.md .yardopts])
  end

  describe "custom watchers" do
    subject(:plugin) { described_class.new(watchers: [Guard::Watcher.new(%r{^templates/})]) }

    it "watches only what the Guardfile asks for" do
      expect(Guard::Watcher.match_files(plugin, %w[a.rb templates/x.erb])).to eq(%w[templates/x.erb])
    end

    it "regenerates for a watched file boondoc does not read" do
      plugin.start
      FileUtils.rm_rf("docs")
      plugin.run_on_modifications(%w[templates/x.erb])

      expect(File).to exist("docs/Widget.md")
    end

    context "when a watcher matches the output directory" do
      subject(:plugin) { described_class.new(watchers: [Guard::Watcher.new(/./)]) }

      let(:runs) { [] }

      before do
        allow(Boondoc::Generator).to receive(:new).and_wrap_original do |original, *args, **opts|
          original.call(*args, **opts).tap do |generator|
            allow(generator).to(receive(:run).and_wrap_original do |run|
              runs << :run
              run.call
            end)
          end
        end
      end

      # Guard reports the files a run wrote, and the plugin is handed those that match a watcher.
      def feed_back_output(rounds)
        rounds.times do
          written = Dir.glob("docs/**/*").select { |f| File.file?(f) }
          plugin.run_on_modifications(Guard::Watcher.match_files(plugin, written))
        end
      end

      it "does not regenerate in response to its own output" do
        plugin.start
        feed_back_output(5)

        expect(runs.size).to eq(1)
      end

      it "still regenerates for a watched file outside the output directory" do
        plugin.start
        feed_back_output(1)
        plugin.run_on_modifications(%w[README.md])

        expect(runs.size).to eq(2)
      end
    end

    it "leaves the default plugin ignoring that file" do
      default = described_class.new
      default.start
      FileUtils.rm_rf("docs")
      default.run_on_modifications(%w[templates/x.erb])

      expect(File).not_to exist("docs/Widget.md")
    end
  end

  describe "#start" do
    it "generates the docs into the configured output directory" do
      write(".boondoc.yml", "output: manual\n")
      plugin.start

      expect(File).to exist("manual/Widget.md")
    end

    it "fails the task when boondoc raises" do
      write(".boondoc.yml", "sources: nothing/**/*.rb\n")

      expect { plugin.start }.to throw_symbol(:task_has_failed)
    end

    it "reports why boondoc failed" do
      write(".boondoc.yml", "sources: nothing/**/*.rb\n")
      catch(:task_has_failed) { plugin.start }

      expect(Guard::Compat::UI).to have_received(:error).with(/no Ruby files matched/)
    end
  end

  describe "the status_file option" do
    subject(:plugin) { described_class.new(status_file: "tmp/docs_status.txt") }

    it "records a successful run" do
      plugin.start

      expect(File.read("tmp/docs_status.txt")).to eq("ok\n")
    end

    it "records a failed run with the reason" do
      write(".boondoc.yml", "sources: nothing/**/*.rb\n")
      catch(:task_has_failed) { plugin.start }

      expect(File.read("tmp/docs_status.txt")).to match(/\Aerror .*no Ruby files matched/)
    end

    it "leaves the file alone when no relevant file changed" do
      plugin.start
      File.delete("tmp/docs_status.txt")
      plugin.run_on_modifications(["Gemfile"])

      expect(File).not_to exist("tmp/docs_status.txt")
    end

    it "writes nothing when not given" do
      described_class.new.start

      expect(File).not_to exist("tmp/docs_status.txt")
    end
  end

  describe "#run_on_modifications" do
    before { plugin.start }

    it "regenerates when a source file changes" do
      write("lib/widget.rb", "# A gadget.\nclass Widget; end\n")
      plugin.run_on_modifications(["lib/widget.rb"])

      expect(File.read("docs/Widget.md")).to include("A gadget.")
    end

    it "regenerates when a source file is added" do
      write("lib/gizmo.rb", "# A gizmo.\nclass Gizmo; end\n")
      plugin.run_on_additions(["lib/gizmo.rb"])

      expect(File).to exist("docs/Gizmo.md")
    end

    it "regenerates when a source file is removed" do
      File.delete("lib/widget.rb")
      write("lib/gizmo.rb", "# A gizmo.\nclass Gizmo; end\n")
      plugin.run_on_removals(["lib/widget.rb"])

      expect(File).not_to exist("docs/Widget.md")
    end

    it "follows a change to .boondoc.yml" do
      write(".boondoc.yml", "output: manual\n")
      plugin.run_on_modifications([".boondoc.yml"])

      expect(File).to exist("manual/Widget.md")
    end

    it "ignores files boondoc does not read" do
      File.delete("docs/Widget.md")
      plugin.run_on_modifications(["Gemfile", "docs/Widget.md"])

      expect(File).not_to exist("docs/Widget.md")
    end

    it "ignores the output directory even when it matches an asset pattern" do
      write(".boondoc.yml", "assets: ['**/*.png']\n")
      plugin.run_on_modifications([".boondoc.yml"])
      File.delete("docs/Widget.md")
      plugin.run_on_modifications(["docs/logo.png"])

      expect(File).not_to exist("docs/Widget.md")
    end

    it "regenerates when a file matching the asset patterns changes" do
      write(".boondoc.yml", "assets: ['images/*.png']\n")
      plugin.run_on_modifications([".boondoc.yml"])
      File.delete("docs/Widget.md")
      plugin.run_on_modifications(["images/logo.png"])

      expect(File).to exist("docs/Widget.md")
    end
  end

  describe "#run_on_modifications after a failed start" do
    it "tries again on any change, since nothing is known about the inputs" do
      write(".boondoc.yml", "sources: nothing/**/*.rb\n")
      catch(:task_has_failed) { plugin.start }
      write(".boondoc.yml", "sources: lib/**/*.rb\n")
      plugin.run_on_modifications([".boondoc.yml"])

      expect(File).to exist("docs/Widget.md")
    end
  end

  describe "#reload and #run_all" do
    it "regenerate the docs" do
      plugin.reload
      File.delete("docs/Widget.md")
      plugin.run_all

      expect(File).to exist("docs/Widget.md")
    end
  end
end
