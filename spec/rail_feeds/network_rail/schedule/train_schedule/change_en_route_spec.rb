# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::TrainSchedule::ChangeEnRoute do
  let(:line) do
    'CRttttttt4ccssss1111 22222222pPPPtttt333ooooooelr CCCCBBBB    uuuuu             '
  end

  subject do
    described_class.new(
      tiploc: 'ttttttt',
      tiploc_suffix: 4,
      category: 'cc',
      signalling_headcode: 'ssss',
      reservation_headcode: 1111,
      service_code: 22222222,
      portion_id: 'p',
      power_type: 'PPP',
      timing_load: 'tttt',
      speed: 333,
      operating_characteristics: 'oooooo',
      seating_class: 'e',
      sleeping_class: 'l',
      reservations: 'r',
      catering: 'CCCC',
      branding: 'BBBB',
      uic_code: 'uuuuu'
    )
  end

  describe '::from_cif' do
    it 'Sets attributes' do
      subject = described_class.from_cif line

      expect(subject.tiploc).to eq 'ttttttt'
      expect(subject.tiploc_suffix).to eq 4
      expect(subject.category).to eq 'cc'
      expect(subject.signalling_headcode).to eq 'ssss'
      expect(subject.reservation_headcode).to eq 1111
      expect(subject.service_code).to eq 22222222
      expect(subject.portion_id).to eq 'p'
      expect(subject.power_type).to eq 'PPP'
      expect(subject.timing_load).to eq 'tttt'
      expect(subject.speed).to eq 333
      expect(subject.operating_characteristics).to eq 'oooooo'
      expect(subject.seating_class).to eq 'e'
      expect(subject.sleeping_class).to eq 'l'
      expect(subject.reservations).to eq 'r'
      expect(subject.catering).to eq 'CCCC'
      expect(subject.branding).to eq 'BBBB'
      expect(subject.uic_code).to eq 'uuuuu'
    end

    it 'Fails for invalid line' do
      expect { described_class.from_cif('bad line') }
        .to raise_error ArgumentError, "Invalid line:\nbad line"
    end
  end

  it '#apply_to' do
    train = double RailFeeds::NetworkRail::Schedule::TrainSchedule
    expect(train).to receive(:category=).with('cc')
    expect(train).to receive(:signalling_headcode=).with('ssss')
    expect(train).to receive(:reservation_headcode=).with(1111)
    expect(train).to receive(:service_code=).with(22222222)
    expect(train).to receive(:portion_id=).with('p')
    expect(train).to receive(:power_type=).with('PPP')
    expect(train).to receive(:timing_load=).with('tttt')
    expect(train).to receive(:speed=).with(333)
    expect(train).to receive(:operating_characteristics=).with('oooooo')
    expect(train).to receive(:seating_class=).with('e')
    expect(train).to receive(:sleeping_class=).with('l')
    expect(train).to receive(:reservations=).with('r')
    expect(train).to receive(:catering=).with('CCCC')
    expect(train).to receive(:branding=).with('BBBB')
    expect(train).to receive(:uic_code=).with('uuuuu')
    subject.apply_to train
  end

  describe '#hash' do
    it 'Uses tiploc and tiploc_suffix' do
      expect(subject.hash).to eq 'ttttttt-4'
    end
  end

  it '#to_cif' do
    expect(subject.to_cif).to eq "#{line}\n"
  end

  describe '#==' do
    let(:change1) { described_class.new tiploc: 'a', tiploc_suffix: 1 }
    let(:change2) { described_class.new tiploc: 'a', tiploc_suffix: 1 }

    it 'Neither tiploc or tiploc_suffix match' do
      change1.tiploc = 'b'
      change1.tiploc_suffix = 2
      expect(change1).to_not eq change2
    end

    it 'Tiploc matches but tiploc_suffix doesn\'t' do
      change1.tiploc_suffix = 2
      expect(change1).to_not eq change2
    end

    it 'Tiploc_suffix matches but tiploc doesn\'t' do
      change1.tiploc = 'b'
      expect(change1).to_not eq change2
    end

    it 'Both tiploc and tiploc_suffix match' do
      expect(change1).to eq change2
    end

    it 'Compares to nil without error' do
      expect(change1).to_not eq nil
    end
  end
end
