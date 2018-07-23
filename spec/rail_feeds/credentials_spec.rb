# frozen_string_literal: true

describe RailFeeds::Credentials do
  context 'Using system wide credentials' do
    subject { described_class.new }

    before :each do
      described_class.configure(
        username: 'user@example.com',
        password: 'P@55word'
      )
    end

    it 'Sets class attributes' do
      expect(described_class.username).to eq 'user@example.com'
      expect(described_class.password).to eq 'P@55word'
    end

    it 'A new instance defaults to class attributes' do
      expect(subject.username).to eq 'user@example.com'
      expect(subject.password).to eq 'P@55word'
    end
  end

  context 'Using specific credentials' do
    subject do
      described_class.new(
        username: 'user2@example.com',
        password: 'P@55word2'
      )
    end

    before :each do
      described_class.configure username: nil, password: nil
    end

    it 'Sets instance attributes' do
      expect(subject.username).to eq 'user2@example.com'
      expect(subject.password).to eq 'P@55word2'
    end

    it 'Leaves class attributes alone' do
      expect(described_class.username).to eq ''
      expect(described_class.password).to eq ''
    end
  end

  describe 'Outputs an array' do
    subject { described_class.new username: 'user-i', password: 'pass-i' }

    it '::to_a' do
      described_class.configure username: 'user', password: 'pass'
      expect(described_class.to_a).to eq ['user', 'pass']
    end

    it '#to_a' do
      expect(subject.to_a).to eq ['user-i', 'pass-i']
    end
  end

  describe 'Outputs a hash' do
    subject { described_class.new username: 'user-i', password: 'pass-i' }

    it '::to_h' do
      described_class.configure username: 'user', password: 'pass'
      expect(described_class.to_h).to eq({ username: 'user', password: 'pass' })
    end

    it '#to_h' do
      expect(subject.to_h).to eq({ username: 'user-i', password: 'pass-i' })
    end
  end
end
