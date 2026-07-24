# frozen_string_literal: true

require "shellwords"

module MotdForge
  # Composes the final banner: a big title (via `figlet` if it's installed,
  # else a plain bordered header), system stats, and a random quote.
  class Banner
    def initialize(title:, stats: SystemStats.capture, quote: Quotes.new.pick)
      @title = title
      @stats = stats
      @quote = quote
    end

    def render
      [render_title, render_stats, render_quote].compact.join("\n")
    end

    private

    def render_title
      figlet_title || plain_title
    end

    def figlet_title
      return unless figlet_available?

      output = `figlet #{Shellwords.escape(@title)} 2>/dev/null`
      output.empty? ? nil : output.rstrip
    end

    def figlet_available?
      return @figlet_available if defined?(@figlet_available)

      @figlet_available = system("which figlet > /dev/null 2>&1")
    end

    def plain_title
      border = "=" * (@title.length + 4)
      "#{border}\n| #{@title} |\n#{border}"
    end

    def render_stats
      "Uptime: #{@stats.uptime} | " \
        "Disk: #{@stats.disk_usage_percent} used | " \
        "Mem: #{@stats.mem_used}/#{@stats.mem_total} (#{@stats.mem_used_percent})"
    end

    def render_quote
      %("#{@quote}") if @quote
    end
  end
end
