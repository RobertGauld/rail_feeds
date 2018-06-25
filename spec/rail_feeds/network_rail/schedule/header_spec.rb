# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Header do
  it '::from_cif' do
    line = double String
    header = double RailFeeds::NetworkRail::Schedule::Header::CIF
    expect(RailFeeds::NetworkRail::Schedule::Header::CIF)
      .to receive(:from_cif).with(line).and_return(header)
    expect(described_class.from_cif(line)).to eq header
  end

  it '::from_json' do
    line = double String
    header = double RailFeeds::NetworkRail::Schedule::Header::JSON
    expect(RailFeeds::NetworkRail::Schedule::Header::JSON)
      .to receive(:from_json).with(line).and_return(header)
    expect(described_class.from_json(line)).to eq header
  end
end
