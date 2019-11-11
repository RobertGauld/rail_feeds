# frozen_string_literal: true

describe RailFeeds::NationalRail::HTTPClient do
  let(:uri) { double URI }

  it 'Is a RailFeeds::HTTPClient' do
    expect(described_class).to be < RailFeeds::HTTPClient
  end

  it 'has correct default credentials' do
    expect(subject.send(:credentials)).to eq RailFeeds::NationalRail::Credentials
  end

  describe '#fetch' do
    context 'Gets an auth token when' do
      before(:each) { allow(uri).to receive(:open) }

      it 'It has not been fetched yet' do
        expect(subject).to receive(:auth_token)
        expect(URI).to receive(:parse).with('https://opendata.nationalrail.co.uk/path').and_return(uri)
        subject.fetch('path') {}
      end

      it 'Token is over an hour old' do
        expect(subject).to receive(:auth_token).twice
        expect(URI).to receive(:parse).with('https://opendata.nationalrail.co.uk/path')
                                      .and_return(uri).twice
        subject.fetch('path') {} # Get the auth token
        Timecop.travel 3601
        subject.fetch('path') {} # Token expired so should reget it
      end

      it 'Getting the token' do
        subject = described_class.new(credentials: RailFeeds::Credentials.new(username: '', password: ''))
        response = double Net::HTTPCreated
        expect(response).to receive(:value)
        expect(response).to receive(:body).and_return('{"token":"TOKEN"}')
        expect(Net::HTTP).to receive(:post_form)
          .with(URI('https://opendata.nationalrail.co.uk/authenticate'), { username: '', password: '' })
          .and_return(response)
        expect(subject.send(:auth_token)).to eq 'TOKEN'
      end
    end

    context 'Has a valid auth_token' do
      before :each do
        allow(subject).to receive(:auth_token).and_return('auth_token')
      end

      it 'Adds server to path then delegates to super' do
        expect(URI).to receive(:parse).with('https://opendata.nationalrail.co.uk/path').and_return(uri)
        expect(uri).to receive(:open)
        subject.fetch('path') {}
      end
    end
  end
end
