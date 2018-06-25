# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Header::JSON do
  subject { described_class.new sequence: 2200 }

  it '::from_json' do
    subject = described_class.from_json(
      '{"JsonTimetableV1":{"timestamp":1529708668,"Metadata":{"sequence":2200}}}'
    )

    expect(subject.extracted_at).to eq Time.new 2018, 6, 23, 0, 4, 28
    expect(subject.sequence).to eq 2200
    expect(subject.start_date).to eq Date.new 2018, 6, 22
  end

  it '#to_json' do
    expect(subject.to_json).to eq '{"JsonTimetableV1":{"classification":"public","time' \
                                  'stamp":0,"owner":"Network Rail","Sender":{"organisa' \
                                  'tion":"","application":"NTROD","component":"SCHEDUL' \
                                  'E"},"Metadata":{"type":"full","sequence":2200}}}'
  end

  describe '#hash' do
    it 'Uses sequence' do
      expect(subject.hash).to eq 2200
    end
  end

  describe '#<=>' do
    let(:header1) { described_class.new sequence: 1 }
    let(:header2) { described_class.new sequence: 1 }

    it 'Doesn\'t match' do
      header2.sequence = 2
      expect(header1.<=>(header2)).to eq(-1)
      expect(header2.<=>(header1)).to eq 1
    end

    it 'Matches' do
      expect(header1.<=>(header2)).to eq 0
    end

    it 'Compares to nil without error' do
      expect { header1 <=> nil }.to_not raise_error
    end
  end

  it '#to_s' do
    expect(subject.to_s).to eq 'Sequence 2200, proabbly from 2018-06-22.'
  end
end
