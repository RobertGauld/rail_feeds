describe RailFeeds::NetworkRail::HTTPClient do
  subject { described_class.new credentials: credentials, logger: logger }
  let :credentials do
    RailFeeds::NetworkRail::Credentials.new username: 'a', password: 'b'
  end
  let(:logger) { double Logger }

  it 'Adds credentials when getting path' do
    uri = URI('https://a:b@datafeeds.networkrail.co.uk/path')
    expect(Net::HTTP).to receive(:get).with(uri).and_return('response body')
    expect(subject.get('path')).to eq 'response body'
  end

  it 'Passes http response to a passed block' do
    uri = URI('https://a:b@datafeeds.networkrail.co.uk/path')
    request = double Net::HTTP::Get
    http = double Net::HTTP
    block = proc { nil }
    expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)
    expect(Net::HTTP).to receive(:new)
      .with('datafeeds.networkrail.co.uk', 443, use_ssl: true).and_return(http)
    expect(http).to receive(:request).with(request, &block)

    expect { subject.get('path', &block) }.to_not raise_error
  end
end
