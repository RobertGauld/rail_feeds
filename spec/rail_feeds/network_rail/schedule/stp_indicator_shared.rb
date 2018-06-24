# frozen_string_literal: true

shared_examples 'it has an STP indicator' do
  describe 'Setting valid values' do
    it ':permanent' do
      subject.stp_indicator = :permanent
      expect(subject.stp_indicator).to eq :permanent
    end

    it '"P"' do
      subject.stp_indicator = 'P'
      expect(subject.stp_indicator).to eq :permanent
    end

    it ':stp_new' do
      subject.stp_indicator = :stp_new
      expect(subject.stp_indicator).to eq :stp_new
    end

    it '"N"' do
      subject.stp_indicator = 'N'
      expect(subject.stp_indicator).to eq :stp_new
    end

    it ':stp_overlay' do
      subject.stp_indicator = :stp_overlay
      expect(subject.stp_indicator).to eq :stp_overlay
    end

    it '"O"' do
      subject.stp_indicator = 'O'
      expect(subject.stp_indicator).to eq :stp_overlay
    end

    it ':stp_cancellation' do
      subject.stp_indicator = :stp_cancellation
      expect(subject.stp_indicator).to eq :stp_cancellation
    end

    it '"C"' do
      subject.stp_indicator = 'C'
      expect(subject.stp_indicator).to eq :stp_cancellation
    end
  end

  it 'Setting invalid values' do
    expect { subject.stp_indicator = :invalid }.to raise_error ArgumentError, /^value \(:invalid\) is invalid, must be any of: /
  end
end
