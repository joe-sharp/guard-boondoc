## [Unreleased]

## [0.1.1] - 2026-10-26

### 🐛 Bug Fixes
- **Gem packaging:** the gemspec now ships `LICENSE.txt` (previously matched as `LICENSE`, so it was omitted) and `CODE_OF_CONDUCT.md`.

## [0.1.0] - 2026-10-26

### ✨ Features
- **`guard :boondoc` plugin:** regenerates your Boondoc markdown docs whenever the watched files change.
- **`status_file` option:** records the outcome of each run.
- **Guardfile `watch` lines:** these override the files Boondoc would otherwise watch. Changes to the output directory never trigger a regeneration.
