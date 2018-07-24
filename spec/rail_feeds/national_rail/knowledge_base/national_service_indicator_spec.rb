# frozen_string_literal: true

describe RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator do
  let :xml do
    <<~HEREDOC
      <?xml version="1.0" encoding="utf-8"?>
      <NSI xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://internal.nationalrail.co.uk/xml/XsdSchemas/External/Version4.0/nre-service-indicator-v4-0.xsd" xmlns="http://nationalrail.co.uk/xml/serviceindicator">
        <TOC>
          <TocCode>AW</TocCode>
          <TocName>Arriva Trains Wales</TocName>
          <Status>Good service</Status>
          <StatusImage>icon-tick2.png</StatusImage>
          <TwitterAccount>ArrivaTW</TwitterAccount>
          <AdditionalInfo><![CDATA[Follow us on Twitter]]></AdditionalInfo>
        </TOC>
        <TOC>
          <TocCode>WM</TocCode>
          <TocName>West Midlands Railway</TocName>
          <Status>Major delays on some routes</Status>
          <StatusImage>icon-disruption.png</StatusImage>
          <StatusDescription><![CDATA[An amended service is in operation]]></StatusDescription>
          <ServiceGroup>
            <GroupName>Aston</GroupName>
            <CurrentDisruption>36DB32F7EB7F40ACACFF1D5CF7572D4C</CurrentDisruption>
            <CustomDetail><![CDATA[Read about this disruption]]></CustomDetail>
            <CustomURL>http://www.nationalrail.co.uk/</CustomURL>
          </ServiceGroup>
          <TwitterAccount>WestMidRailway</TwitterAccount>
          <AdditionalInfo><![CDATA[Latest travel news]]></AdditionalInfo>
        </TOC>
      </NSI>
    HEREDOC
  end
  let(:http_client) { double RailFeeds::NationalRail::HTTPClient }
  let(:temp_file) { double Tempfile }


  describe '::download' do
    it 'Using default credentials' do
      expect(RailFeeds::NationalRail::HTTPClient).to receive(:new)
        .with(credentials: RailFeeds::NationalRail::Credentials).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('darwin/api/staticfeeds/4.0/serviceIndicators', 'file')
      described_class.download 'file'
    end

    it 'Using passed credentials' do
      credentials = double RailFeeds::NationalRail::Credentials
      expect(RailFeeds::NationalRail::HTTPClient).to receive(:new)
        .with(credentials: credentials).and_return(http_client)
      expect(http_client).to receive(:download)
      described_class.download 'file', credentials
    end
  end

  describe '::fetch' do
    it 'Using default credentials' do
      expect(RailFeeds::NationalRail::HTTPClient).to receive(:new)
        .with(credentials: RailFeeds::NationalRail::Credentials).and_return(http_client)
      expect(http_client).to receive(:fetch)
        .with('darwin/api/staticfeeds/4.0/serviceIndicators').and_return(temp_file)
      expect(described_class.fetch).to eq temp_file
    end

    it 'Using passed credentials' do
      credentials = double RailFeeds::NationalRail::Credentials
      expect(RailFeeds::NationalRail::HTTPClient).to receive(:new)
        .with(credentials: credentials).and_return(http_client)
      expect(http_client).to receive(:fetch).and_return(temp_file)
      expect(described_class.fetch(credentials)).to eq temp_file
    end
  end

  it '::load_data' do
    expect(File).to receive(:read).with('filename').and_return(xml)
    data = described_class.load_file('filename')

    expect(data[0].code).to eq 'AW'
    expect(data[0].name).to eq 'Arriva Trains Wales'
    expect(data[0].twitter_account).to eq 'ArrivaTW'
    expect(data[0].additional_info).to eq 'Follow us on Twitter'
    expect(data[0].status.title).to eq 'Good service'
    expect(data[0].status.description).to eq nil
    expect(data[0].status.image).to eq 'icon-tick2.png'
    expect(data[0].service_groups).to eq []

    expect(data[1].code).to eq 'WM'
    expect(data[1].name).to eq 'West Midlands Railway'
    expect(data[1].twitter_account).to eq 'WestMidRailway'
    expect(data[1].additional_info).to eq 'Latest travel news'
    expect(data[1].status.title).to eq 'Major delays on some routes'
    expect(data[1].status.description).to eq 'An amended service is in operation'
    expect(data[1].status.image).to eq 'icon-disruption.png'
    expect(data[1].service_groups[0].disruption_id).to eq '36DB32F7EB7F40ACACFF1D5CF7572D4C'
    expect(data[1].service_groups[0].name).to eq 'Aston'
    expect(data[1].service_groups[0].detail).to eq 'Read about this disruption'
    expect(data[1].service_groups[0].url).to eq 'http://www.nationalrail.co.uk/'
  end

  it '::fetch_data' do
    expect(described_class).to receive(:fetch)
      .with(credentials: RailFeeds::NationalRail::Credentials)
      .and_yield(temp_file)

    expect(temp_file).to receive(:read).and_return(xml)
    expect(described_class).to receive(:parse_xml).with(xml)
    described_class.fetch_data
  end

  it 'Converts to string' do
    expect(File).to receive(:read).with('filename').and_return(xml)
    data = described_class.load_file('filename')
    expect(data[0].to_s).to eq "AW - Arriva Trains Wales\n" \
                               "Good service -  - icon-tick2.png\n\n" \
                               '@ArrivaTW - Follow us on Twitter'
    expect(data[1].to_s).to eq "WM - West Midlands Railway\n" \
                               "Major delays on some routes - An amended service is in operation - icon-disruption.png\n" \
                               "Aston - Read about this disruption\n" \
                               "36DB32F7EB7F40ACACFF1D5CF7572D4C http://www.nationalrail.co.uk/\n" \
                               '@WestMidRailway - Latest travel news'
  end
end
