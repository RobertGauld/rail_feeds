# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Tiploc do
  let(:line) do
    'TIttttttt  123456ATPS Description           54321    CrsNLC Description         '
  end
  subject { described_class.from_cif line }

  describe '::from_cif' do
    it 'Sets attributes' do
      expect(subject.tiploc).to eq 'ttttttt'
      expect(subject.nlc).to eq 123456
      expect(subject.nlc_check_char).to eq 'A'
      expect(subject.tps_description).to eq 'TPS Description'
      expect(subject.stanox).to eq 54321
      expect(subject.crs).to eq 'Crs'
      expect(subject.nlc_description).to eq 'NLC Description'
    end

    it 'Fails for invalid line' do
      expect { described_class.from_cif('bad line') }
        .to raise_error ArgumentError, "Invalid line:\nbad line"
    end
  end

  it '#to_cif' do
    expect(subject.to_cif).to eq "#{line}\n"
  end

  describe '#hash' do
    it 'Uses tiploc' do
      subject.tiploc = 'TIPLOC'
      expect(subject.hash).to eq 'TIPLOC'
    end
  end

  describe '#<=>' do
    let(:tiploc1) { described_class.new tiploc: 'A' }
    let(:tiploc2) { described_class.new tiploc: 'B' }

    it 'Match' do
      tiploc2.tiploc = 'A'
      expect(tiploc1 <=> tiploc2).to eq 0
      expect(tiploc2 <=> tiploc1).to eq 0
    end

    it 'Doesn\'t match' do
      expect(tiploc1 <=> tiploc2).to eq(-1)
      expect(tiploc2 <=> tiploc1).to eq 1
    end

    it 'Compares to nil without error' do
      expect { tiploc1 <=> nil }.to_not raise_error
    end
  end
end
