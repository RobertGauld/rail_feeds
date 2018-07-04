# frozen_string_literal: true

describe RailFeeds::NetworkRail::CORPUS do
  let :json do
    '{"TIPLOCDATA":[{"NLCDESC":"MERSEYRAIL ELECTRICS","NLC":"8","TIPLOC":"MERSELE","3A' \
    'LPHA":"ABC","STANOX":"1","NLCDESC16":"MPTE HQ","UIC":"2"},{"NLCDESC":" ","NLC":" ' \
    '","TIPLOC":" ","3ALPHA":" ","STANOX":" ","NLCDESC16":" ","UIC":" "}]}'
  end
  let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
  let(:reader) { double Zlib::GzipReader }

  describe '::download' do
    let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
    let(:temp_file) { double Tempfile }

    it 'Using default credentials' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new)
        .with(credentials: RailFeeds::NetworkRail::Credentials).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/SupportingFileAuthenticate?type=CORPUS').and_return(temp_file)
      expect(described_class.download).to eq temp_file
    end

    it 'Using passed credentials' do
      credentials = double RailFeeds::NetworkRail::Credentials
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new)
        .with(credentials: credentials).and_return(http_client)
      expect(http_client).to receive(:download).and_return(temp_file)
      expect(described_class.download(credentials: credentials)).to eq temp_file
    end
  end

  describe '::load_file' do
    it 'json file' do
      expect(Zlib::GzipReader).to receive(:open).with('filename') { fail Zlib::GzipFile::Error }
      expect(File).to receive(:read).with('filename').and_return(json)
      data = described_class.load_file('filename')
      expect(data[0].tiploc).to eq 'MERSELE'
      expect(data[0].stanox).to eq 1
      expect(data[0].crs).to eq 'ABC'
      expect(data[0].uic).to eq 2
      expect(data[0].nlc).to eq '8'
      expect(data[0].nlc_description).to eq 'MERSEYRAIL ELECTRICS'
      expect(data[0].nlc_short_description).to eq 'MPTE HQ'
      expect(data[1].tiploc).to be_nil
      expect(data[1].stanox).to be_nil
      expect(data[1].crs).to be_nil
      expect(data[1].uic).to be_nil
      expect(data[1].nlc).to be_nil
      expect(data[1].nlc_description).to be_nil
      expect(data[1].nlc_short_description).to be_nil
    end

    it 'json.gz file' do
      expect(Zlib::GzipReader).to receive(:open).with('filename')
                                                .and_yield(StringIO.new(json))
      expect(described_class.load_file('filename').count).to eq 2
    end
  end

  it '::fetch_data' do
    expect(RailFeeds::NetworkRail::HTTPClient)
      .to receive(:new).with(credentials: RailFeeds::NetworkRail::Credentials)
                       .and_return(http_client)
    expect(http_client).to receive(:fetch_unzipped)
      .with('ntrod/SupportingFileAuthenticate?type=CORPUS')
      .and_yield(reader)
    expect(reader).to receive(:read).and_return(json)
    expect(described_class.fetch_data.count).to eq 2
  end
end
