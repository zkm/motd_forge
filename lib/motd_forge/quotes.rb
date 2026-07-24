# frozen_string_literal: true

module MotdForge
  # Picks a random quote to print under the banner. Ships with a small
  # built-in set and can be extended with a plain-text file, one quote per line.
  class Quotes
    DEFAULT = [
      "It's not a bug, it's an undocumented feature.",
      "There's no place like 127.0.0.1.",
      "Rebooting the router fixes everything, eventually.",
      "In case of fire: git commit, git push, then evacuate.",
      "99 little bugs in the code, 99 little bugs...",
      "The cloud is just someone else's computer. This one's yours."
    ].freeze

    def initialize(file: nil)
      @file = file
    end

    def pick
      pool.sample
    end

    private

    def pool
      return DEFAULT unless @file

      lines = File.readlines(@file, chomp: true).reject(&:empty?)
      lines.empty? ? DEFAULT : lines
    rescue Errno::ENOENT
      DEFAULT
    end
  end
end
