# frozen_string_literal: true

describe RailFeeds::NetworkRail::HTTPClient do
  let(:temp_file) { double Tempfile }
  before(:each) { allow(temp_file).to receive(:delete) }

  describe '#get' do
    it 'Yields what uri.open does' do
      uri = double URI
      expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      expect { |a| subject.get('path', &a) }.to yield_with_args(temp_file)
    end

    it 'Adds credentials when getting path' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'user',
        password: 'pass'
      )
      uri = double URI
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open)
        .with(http_basic_authentication: ['user', 'pass'])
        .and_return(temp_file)
      subject = described_class.new credentials: credentials
      subject.get('path') {}
    end

    it 'Handles special characters in credentials' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'a@example.com',
        password: '!:@'
      )
      uri = double URI
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      subject = described_class.new credentials: credentials
      expect { subject.get('path') {} }.to_not raise_error
    end

    it 'Deletes tempfile' do
      uri = double URI
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      expect(temp_file).to receive(:delete)
      subject.get('path') {}
    end
  end

  describe '#get_unzipped' do
    it 'Returns what Zlib::GzipReader.open does' do
      reader = double Zlib::GzipReader
      expect(subject).to receive(:get).with('path').and_yield(temp_file)
      expect(temp_file).to receive(:path).and_return('gz_file_path')
      expect(Zlib::GzipReader).to receive(:open).with('gz_file_path').and_return(reader)
      expect { |a| subject.get_unzipped('path', &a) }.to yield_with_args(reader)
    end
  end
end
