# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::TrainSchedule::Location::Origin do
  subject { described_class.new tiploc: 'aaaaaaa', tiploc_suffix: 1 }
  let(:line) do
    'LOttttttt1dddddDDDDPlaLin2H3 aaaaaaaaaaaa45                                     '
  end

  describe '::from_cif' do
    it 'Sets attributes' do
      subject = described_class.from_cif line

      expect(subject.tiploc).to eq 'ttttttt'
      expect(subject.tiploc_suffix).to eq 1
      expect(subject.scheduled_departure).to eq 'ddddd'
      expect(subject.public_departure).to eq 'DDDD'
      expect(subject.platform).to eq 'Pla'
      expect(subject.line).to eq 'Lin'
      expect(subject.engineering_allowance).to eq 2.5
      expect(subject.pathing_allowance).to eq 3.0
      expect(subject.activity).to eq 'aaaaaaaaaaaa'
      expect(subject.performance_allowance).to eq 45.0
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
      expect(subject.hash).to eq 'aaaaaaa-1'
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
