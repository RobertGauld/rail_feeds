# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule do
  describe '::nil_or_i' do
    it 'Empty value' do
      expect(described_class.nil_or_i(' ')).to be_nil
    end
    it 'Nonempty value' do
      expect(described_class.nil_or_i(' 1 ')).to eq 1
    end
  end

  describe '::nil_or_strip' do
    it 'Empty value' do
      expect(described_class.nil_or_strip(' ')).to be_nil
    end
    it 'Nonempty value' do
      expect(described_class.nil_or_strip(' 1 ')).to eq '1'
    end
  end

  describe '::make_date' do
    context 'Empty value' do
      it 'Empty values not allowed' do
        expect { described_class.make_date('      ') }.to raise_error ArgumentError, 'invalid date'
      end
      it 'Empty values allowed' do
        expect(described_class.make_date('      ', allow_nil: true)).to be_nil
      end
    end

    context 'Nonempty value' do
      it 'Normal date' do
        expect(described_class.make_date('050607')).to eq Date.new(2005, 6, 7)
      end
      it '999999' do
        expect(described_class.make_date('999999')).to eq Date.new(9999, 12, 31)
      end
    end
  end
end
