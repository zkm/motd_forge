# frozen_string_literal: true

RSpec.describe MotdForge::Quotes do
  it "picks a quote from the default set" do
    expect(described_class::DEFAULT).to include(described_class.new.pick)
  end

  it "falls back to defaults when the custom file is missing" do
    quotes = described_class.new(file: "/nonexistent/path.txt")
    expect(described_class::DEFAULT).to include(quotes.pick)
  end

  it "reads quotes from a custom file when present" do
    file = Tempfile.new("quotes")
    file.write("Only quote here\n")
    file.close

    quotes = described_class.new(file: file.path)
    expect(quotes.pick).to eq("Only quote here")
  ensure
    file&.unlink
  end
end
