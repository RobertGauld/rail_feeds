# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Header::CIF do
  let(:line) do
    +'HDa                   0102030405b      c      de060708091011                    '
  end
  subject { described_class.from_cif line }

  describe 'Sets attributes' do
    it(':file_identity') { expect(subject.file_identity).to eq 'a' }
    it(':extracted_at') { expect(subject.extracted_at).to eq Time.new(2003, 2, 1, 4, 5, 0, 0) }
    it(':current_file_reference') { expect(subject.current_file_reference).to eq 'b' }
    it(':previous_file_reference') { expect(subject.previous_file_reference).to eq 'c' }
    it(':update_indicator') { expect(subject.update_indicator).to eq 'd' }
    it(':version') { expect(subject.version).to eq 'e' }
    it(':start_date') { expect(subject.start_date).to eq Date.new(2008, 7, 6) }
    it(':end_date') { expect(subject.end_date).to eq Date.new(2011, 10, 9) }
  end

  describe 'Helper methods' do
    context 'A full extract' do
      before(:each) { line[46] = 'F' }
      it { should_not be_update }
      it { should be_full }
    end

    context 'An update extract' do
      before(:each) { line[46] = 'U' }
      it { should be_update }
      it { should_not be_full }
    end
  end

  it '#to_cif' do
    expect(subject.to_cif).to eq "#{line}\n"
  end

  describe '#hash' do
    it 'Uses current_file_reference' do
      expect(subject.hash).to eq 'b'
    end
  end

  describe '#==' do
    let(:header1) { described_class.new current_file_reference: 'a' }
    let(:header2) { described_class.new current_file_reference: 'a' }

    it 'Doesn\'t match' do
      header1.current_file_reference = nil
      expect(header1).to_not eq header2
    end

    it 'Matches' do
      expect(header1).to eq header2
    end

    it 'Compares to nil without error' do
      expect(header1).to_not eq nil
    end
  end

  it '#to_s' do
    expect(subject.to_s).to eq 'File "a" (version e) at ' \
                               '2003-02-01 04:05. An update extract for ' \
                               '2008-07-06 to 2011-10-09.'
  end

  it 'Fails to initalize from invalid line' do
    expect { described_class.from_cif('bad line') }
      .to raise_error ArgumentError, "Invalid line:\nbad line"
  end
end
