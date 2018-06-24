# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Train::Location::Intermediate do
  subject { described_class.new tiploc: 'ccccccc', tiploc_suffix: 3 }
  let(:line) do
    'LIttttttt1aaaaadddddpppppAAAADDDDPlaLinPataaaaaaaaaaaa123456                    '
  end

  describe '::from_cif' do
    it 'Sets attributes' do
      subject = described_class.from_cif line

      expect(subject.tiploc).to eq 'ttttttt'
      expect(subject.tiploc_suffix).to eq 1
      expect(subject.scheduled_arrival).to eq 'aaaaa'
      expect(subject.scheduled_departure).to eq 'ddddd'
      expect(subject.scheduled_pass).to eq 'ppppp'
      expect(subject.public_arrival).to eq 'AAAA'
      expect(subject.public_departure).to eq 'DDDD'
      expect(subject.platform).to eq 'Pla'
      expect(subject.line).to eq 'Lin'
      expect(subject.path).to eq 'Pat'
      expect(subject.activity).to eq 'aaaaaaaaaaaa'
      expect(subject.engineering_allowance).to eq 12.0
      expect(subject.pathing_allowance).to eq 34.0
      expect(subject.performance_allowance).to eq 56.0
    end

    it 'Fails for invalid line' do
      expect { described_class.from_cif('bad line') }
        .to raise_error ArgumentError, "Invalid line:\nbad line"
    end
  end

  it '#to_cif' do
    subject = described_class.from_cif line
    expect(subject.to_cif).to eq "#{line}\n"
  end

  describe '#hash' do
    it 'Uses tiploc and tiploc_suffix' do
      expect(subject.hash).to eq 'ccccccc-3'
    end
  end

  describe '#==' do
    let(:location1) { described_class.new tiploc: 'a', tiploc_suffix: 1 }
    let(:location2) { described_class.new tiploc: 'a', tiploc_suffix: 1 }

    it 'Neither tiploc or tiploc_suffix match' do
      location1.tiploc = 'b'
      location1.tiploc_suffix = 2
      expect(location1).to_not eq location2
    end

    it 'Tiploc matches but tiploc_suffix doesn\'t' do
      location1.tiploc_suffix = 2
      expect(location1).to_not eq location2
    end

    it 'Tiploc_suffix matches but tiploc doesn\'t' do
      location1.tiploc = 'b'
      expect(location1).to_not eq location2
    end

    it 'Both tiploc and tiploc_suffix match' do
      expect(location1).to eq location2
    end

    it 'Compares to nil without error' do
      expect(location1).to_not eq nil
    end
  end
end
