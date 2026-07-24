# frozen_string_literal: true

require "optparse"
require "yaml"
require "socket"

module MotdForge
  # Parses CLI flags, merges in an optional YAML config, and prints the banner.
  class CLI
    DEFAULT_CONFIG_PATH = File.expand_path("~/.motd-forge.yml")

    def self.run(argv = ARGV)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv
      @title = Socket.gethostname
      @title_from_cli = false
      @quote_file = nil
      @show_quote = true
      @config_path = DEFAULT_CONFIG_PATH
    end

    def run
      parse_options!
      load_config!

      quote = @show_quote ? Quotes.new(file: @quote_file).pick : nil
      puts Banner.new(title: @title, quote: quote).render
      0
    end

    private

    def parse_options!
      OptionParser.new do |opts|
        opts.banner = "Usage: motd-forge [options]"

        opts.on("-n", "--name NAME", "Title to render (default: hostname)") do |v|
          @title = v
          @title_from_cli = true
        end
        opts.on("-q", "--quote-file FILE", "Custom quotes file, one per line") { |v| @quote_file = v }
        opts.on("--no-quote", "Don't print a quote") { @show_quote = false }
        opts.on("-c", "--config FILE", "Config file (default: #{DEFAULT_CONFIG_PATH})") { |v| @config_path = v }
        opts.on("-v", "--version", "Print the version") do
          puts MotdForge::VERSION
          exit 0
        end
        opts.on("-h", "--help", "Print this help") do
          puts opts
          exit 0
        end
      end.parse!(@argv)
    end

    def load_config!
      return unless File.exist?(@config_path)

      config = YAML.safe_load(File.read(@config_path)) || {}
      @title = config["title"] if config["title"] && !@title_from_cli
      @quote_file ||= config["quote_file"]
    rescue Psych::SyntaxError
      warn "motd-forge: ignoring invalid config at #{@config_path}"
    end
  end
end
