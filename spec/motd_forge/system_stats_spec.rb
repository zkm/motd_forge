# frozen_string_literal: true

RSpec.describe MotdForge::SystemStats do
  describe ".capture" do
    it "returns a snapshot with uptime, disk, and memory fields populated" do
      snapshot = described_class.capture

      expect(snapshot.uptime).to be_a(String)
      expect(snapshot.disk_usage_percent).to be_a(String)
      expect(snapshot.mem_used).to be_a(String)
      expect(snapshot.mem_total).to be_a(String)
      expect(snapshot.mem_used_percent).to be_a(String)
    end
  end
end
