# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`motd_forge` is a small Ruby gem that generates a randomized login banner
(MOTD): a title (rendered big via the `figlet` binary if present, otherwise a
plain bordered header), current uptime/disk/memory stats, and a random quote.
Intended to be run from a shell login script on homelab servers.

There is also an npm/Node.js port with feature parity at
[zkm/motd-forge](https://github.com/zkm/motd-forge) (separate repo,
independent versioning). If a change here affects behavior, output format, or
CLI flags, check whether it should be mirrored there too.

CI mirrors the JS port's: a RuboCop lint job (the port uses Biome), RSpec on
Ruby 3.1 and 3.4, and SimpleCov coverage uploaded to Codecov from the 3.4 run.

## Commands

Bundler is configured to install gems into a project-local `vendor/bundle`
(via `bundle config set --local path 'vendor/bundle'`) rather than the system
gem path, since RubyGems installs there by default and that requires root.
Because of this, `rake` and `rspec` are **not** on `PATH` globally — always
prefix with `bundle exec`, not bare `rake`/`rspec`.

- `bundle install` — install dependencies (also runnable via `bin/setup`)
- `bundle exec rake` — run RSpec then RuboCop (default rake task, what CI checks)
- `bundle exec rake spec` — run the full RSpec suite only
- `COVERAGE=1 bundle exec rake spec` — run specs with SimpleCov; HTML and Cobertura reports land in `coverage/`
- `bundle exec rubocop` / `bundle exec rubocop -a` — lint / apply safe autocorrections
- `bundle exec rspec spec/motd_forge/quotes_spec.rb` — run a single spec file
- `bundle exec rspec spec/motd_forge/quotes_spec.rb:10` — run a single example by line number
- `bin/console` — load the gem into an IRB session for manual testing
- `bundle exec exe/motd-forge` — run the CLI directly from source without installing
- `bundle exec rake install` — build and install the gem locally
- Releases publish automatically: bump `MotdForge::VERSION`, update `CHANGELOG.md`, merge, then publish a GitHub Release tagged `v<version>`. `.github/workflows/publish.yml` lints, runs specs, checks the tag matches the version, and pushes the gem to GitHub Packages and RubyGems.org (trusted publishing, no API key)

## Architecture

- `lib/motd_forge/system_stats.rb` — `SystemStats.capture` returns a `Snapshot`
  struct (uptime, disk usage, memory used/total). Reads `/proc/uptime` and
  `/proc/meminfo` directly on Linux, falling back to shelling out to `uptime`
  and `df` if those aren't available.
- `lib/motd_forge/quotes.rb` — `Quotes#pick` returns a random quote from the
  built-in `DEFAULT` list, or from a user-supplied file (one quote per line)
  passed via `file:`.
- `lib/motd_forge/banner.rb` — `Banner#render` composes the final output:
  title + stats + quote. Title rendering shells out to `figlet` when it's on
  `PATH`, falling back to a plain bordered header otherwise.
- `lib/motd_forge/cli.rb` — `CLI.run(argv)` parses flags with `OptionParser`,
  merges in `~/.motd-forge.yml` (CLI flags win over config file values), then
  builds and prints a `Banner`. This is the only class that touches `ARGV`,
  `STDOUT`, or `exit`, so the other classes stay easy to test in isolation.
- `exe/motd-forge` is a thin wrapper that calls `MotdForge::CLI.run`.

Data flows one direction: `CLI` gathers title/quote-file/config choices ->
builds a `Banner` -> `Banner` pulls a `SystemStats::Snapshot` and a quote ->
renders to a string that `CLI` prints. There's no shared mutable state between
classes; each one takes its inputs via `initialize` and exposes a single
public method (`capture`, `pick`, `render`, `run`).
