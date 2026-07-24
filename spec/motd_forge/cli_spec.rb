# frozen_string_literal: true

RSpec.describe MotdForge::CLI do
  describe "--version" do
    it "prints the version and exits" do
      expect { described_class.run(["--version"]) }
        .to output("#{MotdForge::VERSION}\n").to_stdout
        .and raise_error(SystemExit)
    end
  end

  describe "run" do
    it "renders a banner containing the given name" do
      expect { described_class.run(["--name", "testhost", "--no-quote"]) }
        .to output(/testhost/).to_stdout
    end
  end
end
