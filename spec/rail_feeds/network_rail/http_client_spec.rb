# frozen_string_literal: true

describe RailFeeds::NetworkRail::HTTPClient do
  describe '#get' do
    it 'Returns what uri.open does' do
      uri = double URI
      temp_file = double Tempfile
      expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      expect(subject.get('path')).to eq temp_file
    end

    it 'Adds credentials when getting path' do
      uri = double URI
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open).with(http_basic_authentication: ['user', 'pass'])
      expect(subject.get('path')).to be_nil
    end

    it 'Handles special characters in credentials' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'a@example.com',
        password: '!:@'
      )
      uri = double URI
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open)
      subject = described_class.new credentials: credentials
      expect { subject.get('path') }.to_not raise_error
    end
  end

  describe '#get_unzipped' do
    let(:temp_file) { double Tempfile }
    before :each do
      expect(subject).to receive(:get).and_return(temp_file)
    end

    it 'Returns what Zlib::GzipReader.open does' do
      reader = double Zlib::GzipReader
      expect(temp_file).to receive(:path).and_return('gz_file_path')
      expect(Zlib::GzipReader).to receive(:open).with('gz_file_path').and_return(reader)
      expect(subject.get_unzipped('path')).to eq reader
    end
  end
end
