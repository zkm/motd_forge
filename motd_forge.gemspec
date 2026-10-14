# frozen_string_literal: true

require_relative "lib/motd_forge/version"

Gem::Specification.new do |spec|
  spec.name = "motd_forge"
  spec.version = MotdForge::VERSION
  spec.authors = ["Zach Schneider"]
  spec.email = ["zachschneider@gmail.com"]

  spec.summary = "Generate a randomized login banner (MOTD) with system stats and a quote."
  spec.description = "motd-forge builds a custom message-of-the-day banner showing uptime, " \
                     "disk and memory usage, and a random quote -- handy for homelab servers."
  spec.homepage = "https://github.com/zkm/motd_forge"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.glob("{lib,exe}/**/*") +
               %w[README.md LICENSE.txt CHANGELOG.md motd_forge.gemspec Gemfile Rakefile]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
