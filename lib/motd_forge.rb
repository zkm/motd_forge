# frozen_string_literal: true

require_relative "motd_forge/version"
require_relative "motd_forge/system_stats"
require_relative "motd_forge/quotes"
require_relative "motd_forge/banner"
require_relative "motd_forge/cli"

module MotdForge
  class Error < StandardError; end
end
