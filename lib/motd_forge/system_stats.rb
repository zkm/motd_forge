# frozen_string_literal: true

module MotdForge
  # Reads uptime, disk, and memory usage from the host. Uses /proc on Linux,
  # with a best-effort shell fallback (e.g. `uptime`) elsewhere.
  class SystemStats
    Snapshot = Struct.new(:uptime, :disk_usage_percent, :mem_used, :mem_total, :mem_used_percent)

    def self.capture
      new.capture
    end

    def capture
      Snapshot.new(uptime, disk_usage_percent, *memory)
    end

    private

    def uptime
      seconds = File.read("/proc/uptime").split.first.to_f
      format_duration(seconds)
    rescue Errno::ENOENT
      shell_uptime
    end

    def format_duration(seconds)
      days, rem = seconds.divmod(86_400)
      hours, rem = rem.divmod(3_600)
      minutes, = rem.divmod(60)

      parts = []
      parts << "#{days.to_i}d" if days.positive?
      parts << "#{hours.to_i}h" if hours.positive? || days.positive?
      parts << "#{minutes.to_i}m"
      parts.join(" ")
    end

    def shell_uptime
      `uptime -p`.strip.sub(/\Aup /, "")
    rescue StandardError
      "unknown"
    end

    def disk_usage_percent(path = "/")
      line = `df -kP #{path} 2>/dev/null`.lines[1]
      return "unknown" unless line

      line.split[4]
    rescue StandardError
      "unknown"
    end

    def memory
      meminfo = File.read("/proc/meminfo")
      total_kb = meminfo[/MemTotal:\s+(\d+)/, 1].to_i
      available_kb = meminfo[/MemAvailable:\s+(\d+)/, 1].to_i
      used_kb = total_kb - available_kb

      percent = total_kb.positive? ? ((used_kb.to_f / total_kb) * 100).round : 0
      [kb_to_human(used_kb), kb_to_human(total_kb), "#{percent}%"]
    rescue Errno::ENOENT
      %w[unknown unknown unknown]
    end

    def kb_to_human(kb)
      gb = kb / 1024.0 / 1024.0
      return "#{gb.round(1)}G" if gb >= 1

      "#{(kb / 1024.0).round}M"
    end
  end
end
