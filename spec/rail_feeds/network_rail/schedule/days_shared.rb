# frozen_string_literal: true

shared_examples 'it has a days array' do
  describe 'Setting valid values' do
    it 'Array of 7 booleans' do
      subject.days = [false, true, false, true, false, true, false]
      expect(subject.days).to eq [false, true, false, true, false, true, false]
    end

    it 'String with length of 7' do
      subject.days = '1010101'
      expect(subject.days).to eq [true, false, true, false, true, false, true]
    end
  end

  describe 'Setting invalid values' do
    it 'Array of 6 booleans' do
      subject.days = [false, true, false, true, false, true]
      expect(subject.days).to eq [false, true, false, true, false, true, nil]
    end
    it 'Array of 8 booleans' do
      subject.days = [false, true, false, true, false, true, false, true]
      expect(subject.days).to eq [false, true, false, true, false, true, false]
    end

    it 'String with length of 6' do
      subject.days = '101010'
      expect(subject.days).to eq [true, false, true, false, true, false, nil]
    end
    it 'String with length of 8' do
      subject.days = '10101010'
      expect(subject.days).to eq [true, false, true, false, true, false, true]
    end
  end

  describe 'Query methods' do
    before(:each) { subject.days = '0000000' }

    it '#mondays?' do
      expect(subject.mondays?).to be false
      subject.days = '1000000'
      expect(subject.mondays?).to be true
    end

    it '#tuesdays?' do
      expect(subject.tuesdays?).to be false
      subject.days = '0100000'
      expect(subject.tuesdays?).to be true
    end

    it '#wednesdays?' do
      expect(subject.wednesdays?).to be false
      subject.days = '0010000'
      expect(subject.wednesdays?).to be true
    end

    it '#thursdays?' do
      expect(subject.thursdays?).to be false
      subject.days = '0001000'
      expect(subject.thursdays?).to be true
    end

    it '#fridays?' do
      expect(subject.fridays?).to be false
      subject.days = '0000100'
      expect(subject.fridays?).to be true
    end

    it '#saturdays?' do
      expect(subject.saturdays?).to be false
      subject.days = '0000010'
      expect(subject.saturdays?).to be true
    end

    it '#sundays?' do
      expect(subject.sundays?).to be false
      subject.days = '0000001'
      expect(subject.sundays?).to be true
    end
  end
end
