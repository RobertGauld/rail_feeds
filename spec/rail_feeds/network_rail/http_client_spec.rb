# frozen_string_literal: true

describe RailFeeds::NetworkRail::HTTPClient do
  it 'Is a RailFeeds::HTTPClient' do
    expect(described_class).to be < RailFeeds::HTTPClient
  end

  it 'has correct default credentials' do
    expect(subject.send(:credentials)).to eq RailFeeds::NetworkRail::Credentials
  end

  describe '#fetch' do
    it 'Adds server to path then delegates to super' do
      uri = double URI
      expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
      expect(uri).to receive(:open)
      subject.fetch('path') {}
    end
  end
end
