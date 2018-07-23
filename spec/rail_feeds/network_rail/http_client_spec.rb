# frozen_string_literal: true

describe RailFeeds::NetworkRail::HTTPClient do
  let(:temp_file) { double Tempfile }
  let(:uri) { double URI }

  describe '#download' do
    let(:file) { double File }

    it 'Saves the file' do
      expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      expect(File).to receive(:open).with('file', 'w').and_yield(file)
      expect(IO).to receive(:copy_stream).with(temp_file, file)
      subject.download('path', 'file')
    end

    it 'Adds credentials when getting path' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'user',
        password: 'pass'
      )
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open)
        .with(http_basic_authentication: ['user', 'pass'])
        .and_return(temp_file)
      expect(File).to receive(:open).and_yield(file)
      expect(IO).to receive(:copy_stream).with(temp_file, file)
      subject = described_class.new credentials: credentials
      subject.download('path', 'file')
    end

    it 'Handles special characters in credentials' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'a@example.com',
        password: '!:@'
      )
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      expect(File).to receive(:open).and_yield(file)
      expect(IO).to receive(:copy_stream).with(temp_file, file)
      subject = described_class.new credentials: credentials
      expect { subject.download('path', 'file') }.to_not raise_error
    end
  end

  describe '#fetch' do
    describe 'Yields a TempFile' do
      it 'When uri.open gives a TempFile' do
        expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
        expect(uri).to receive(:open).and_return(temp_file)
        expect { |a| subject.fetch('path', &a) }.to yield_with_args(temp_file)
      end

      it 'When uri.open gives a StringIO' do
        string_io = double StringIO
        expect(URI).to receive(:parse).with('https://datafeeds.networkrail.co.uk/path').and_return(uri)
        expect(uri).to receive(:open).and_return(string_io)
        expect { |a| subject.fetch('path', &a) }.to yield_with_args(string_io)
      end
    end

    it 'Adds credentials when getting path' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'user',
        password: 'pass'
      )
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open)
        .with(http_basic_authentication: ['user', 'pass'])
        .and_return(temp_file)
      subject = described_class.new credentials: credentials
      subject.fetch('path') {}
    end

    it 'Handles special characters in credentials' do
      credentials = RailFeeds::NetworkRail::Credentials.new(
        username: 'a@example.com',
        password: '!:@'
      )
      expect(URI).to receive(:parse).and_return(uri)
      expect(uri).to receive(:open).and_return(temp_file)
      subject = described_class.new credentials: credentials
      expect { subject.fetch('path') {} }.to_not raise_error
    end
  end

  describe '#fetch_unzipped' do
    it 'Returns what Zlib::GzipReader.open does' do
      reader = double Zlib::GzipReader
      expect(subject).to receive(:fetch).with('path').and_yield(temp_file)
      expect(Zlib::GzipReader).to receive(:new).with(temp_file).and_return(reader)
      expect { |a| subject.fetch_unzipped('path', &a) }.to yield_with_args(reader)
    end
  end
end
