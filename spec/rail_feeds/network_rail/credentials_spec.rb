# frozen_string_literal: true

describe RailFeeds::NetworkRail::Credentials do
  subject { described_class.new username: 'user-i', password: 'pass-i' }

  it 'Has seperate values to RailFeeds::Credentials' do
    described_class.configure username: 'a', password: 'b'
    expect(described_class.username).to_not eq RailFeeds::Credentials.username
    expect(described_class.password).to_not eq RailFeeds::Credentials.password
  end

  describe 'Outputs an array' do
    it '::to_a' do
      described_class.configure username: 'user', password: 'pass'
      expect(described_class.to_a).to eq ['user', 'pass']
    end

    it '#to_a' do
      expect(subject.to_a).to eq ['user-i', 'pass-i']
    end
  end
end
