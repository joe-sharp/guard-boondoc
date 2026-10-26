# Class: Guard::Boondoc

- **Inherits:** `Plugin`
- **Defined in:** [`lib/guard/boondoc.rb`](../../lib/guard/boondoc.rb)

Regenerates boondoc documentation when a file boondoc reads changes.

What to watch and where the docs go come from `.boondoc.yml` and
`.yardopts`, which are read again on every run. The only option is
`status_file`, a path the outcome of each run is written to: `ok`, or
`error` followed by boondoc's message.

**Examples:**

*Guardfile*

```ruby
guard :boondoc
```

*Guardfile, recording each run's outcome*

```ruby
guard :boondoc, status_file: 'tmp/docs_status.txt'
```

*Guardfile, overriding what is watched*

```ruby
guard :boondoc do
  watch(%r{^templates/})
end
```

## Constants

### <a id="constant-CONFIG_FILES"></a>`CONFIG_FILES`

```ruby
CONFIG_FILES = [::Boondoc::Config::FILE, '.yardopts'].freeze
```

Files whose change can alter how every other file is read.

### <a id="constant-GLOB_FLAGS"></a>`GLOB_FLAGS`

```ruby
GLOB_FLAGS = File::FNM_PATHNAME | File::FNM_EXTGLOB
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(options = {})`](#method-i-initialize) | Watches every file, then narrows to the ones boondoc reads when they change, since those are only known from the configuration. |
| [`#reload`](#method-i-reload) |  |
| [`#run_all`](#method-i-run_all) |  |
| [`#run_on_additions(paths)`](#method-i-run_on_additions) |  |
| [`#run_on_modifications(paths)`](#method-i-run_on_modifications) |  |
| [`#run_on_removals(paths)`](#method-i-run_on_removals) |  |
| [`#start`](#method-i-start) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(options = {})
```

Watches every file, then narrows to the ones boondoc reads when they change,
since those are only known from the configuration. Watchers given in the
Guardfile replace that, and then decide on their own when to regenerate.

### <a id="method-i-reload"></a>`#reload`

```ruby
def reload
```

**Returns:**

- (`void`)

### <a id="method-i-run_all"></a>`#run_all`

```ruby
def run_all
```

**Returns:**

- (`void`)

### <a id="method-i-run_on_additions"></a>`#run_on_additions`

```ruby
def run_on_additions(paths)
```

- **Alias for:** [`#run_on_modifications`](#method-i-run_on_modifications)

**Parameters:**

- `paths` (`Array<String>`) — files that changed, relative to the project

**Returns:**

- (`void`)

### <a id="method-i-run_on_modifications"></a>`#run_on_modifications`

```ruby
def run_on_modifications(paths)
```

- **Also known as:** [`#run_on_additions`](#method-i-run_on_additions), [`#run_on_removals`](#method-i-run_on_removals)

**Parameters:**

- `paths` (`Array<String>`) — files that changed, relative to the project

**Returns:**

- (`void`)

### <a id="method-i-run_on_removals"></a>`#run_on_removals`

```ruby
def run_on_removals(paths)
```

- **Alias for:** [`#run_on_modifications`](#method-i-run_on_modifications)

**Parameters:**

- `paths` (`Array<String>`) — files that changed, relative to the project

**Returns:**

- (`void`)

### <a id="method-i-start"></a>`#start`

```ruby
def start
```

**Returns:**

- (`void`)
