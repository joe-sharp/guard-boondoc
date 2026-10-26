# guard-boondoc

A [Guard](https://github.com/guard/guard) plugin that regenerates your [Boondoc](https://github.com/joe-sharp/boondoc)
docs when a file Boondoc reads changes.

## Setup

```ruby
# Gemfile
group :development do
  gem 'guard-boondoc'
end
```

```sh
bundle exec guard init boondoc   # adds `guard :boondoc` to your Guardfile
bundle exec guard
```

## What it does

The docs are generated when Guard starts, and again whenever one of these changes, is added, or is removed:

- the Ruby files in `sources`
- the README and the `files` you stitch in
- the files matching `assets`
- `.boondoc.yml` and `.yardopts`

What to build comes from Boondoc's own configuration, not from Guardfile options. The plugin reads `.boondoc.yml` and `.yardopts` on every run, so editing them takes effect
without restarting Guard, and changes inside the output directory never trigger a run.

If Boondoc fails, for example in `strict` mode with warnings, the error is shown and Guard marks the task as
failed. The next change to a file Boondoc reads tries again.

## Overriding what is watched

If you need to regenerate for files Boondoc doesn't read, or want full control, add your own `watch` lines:

```ruby
guard :boondoc do
  watch(%r{^templates/})
  watch('.boondoc.yml')
end
```

Any `watch` turns off the detection described above, so your patterns alone decide when the docs are regenerated.
Changes inside the output directory still never trigger a run, so a broad pattern such as `/\.md$/` is safe.

## Recording the outcome

To let another tool, such as a status line, see how the last run went, give the plugin a `status_file`:

```ruby
guard :boondoc, status_file: 'tmp/docs_status.txt'
```

After each run the file holds `ok`, or `error` followed by Boondoc's message. Its directory is created if needed.

## Development

```sh
bundle exec rake   # specs and RuboCop
```

## License

MIT, see [LICENSE.txt](LICENSE.txt).
