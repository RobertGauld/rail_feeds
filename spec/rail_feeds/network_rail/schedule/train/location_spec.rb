# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Train::Location do
  it 'Can\'t be instantiated' do
    expect { described_class.new }.to raise_error RuntimeError, 'This class should never be instantiated'
  end

  describe 'Make relevant location type from line' do
    it 'Origin' do
      line = 'LO'
      expect(RailFeeds::NetworkRail::Schedule::Train::Location::Origin)
        .to receive(:from_cif).with(line).and_return(:location)
      expect(described_class.from_cif(line)).to eq :location
    end

    it 'Intermediate' do
      line = 'LI'
      expect(RailFeeds::NetworkRail::Schedule::Train::Location::Intermediate)
        .to receive(:from_cif).with(line).and_return(:location)
      expect(described_class.from_cif(line)).to eq :location
    end

    it 'Terminating' do
      line = 'LT'
      expect(RailFeeds::NetworkRail::Schedule::Train::Location::Terminating)
        .to receive(:from_cif).with(line).and_return(:location)
      expect(described_class.from_cif(line)).to eq :location
    end

    it 'Fails on bad line' do
      line = 'bad_line'
      expect { described_class.from_cif(line) }.to raise_error ArgumentError, 'Improper line type ba: bad_line'
    end
  end
end
