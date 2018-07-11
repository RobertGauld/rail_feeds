# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Fetcher do
  let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
  let(:reader) { double Zlib::GzipReader }

  describe '#download_all_full' do
    it 'CIF format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full.CIF.gz', 'file')
      subject.download_all_full :cif, 'file'
    end

    it 'JSON format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full', 'file')
      subject.download_all_full :json, 'file'
    end

    it 'Invalid format' do
      expect { subject.download_all_full :invalid, 'file' }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end
  end

  describe '#download_all_update' do
    it 'CIF format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon.CIF.gz', 'file')
      subject.download_all_update 'mon', :cif, 'file'
    end

    it 'JSON format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-tue', 'file')
      subject.download_all_update 'tue', :json, 'file'
    end

    it 'Invalid format' do
      expect { subject.download_all_update 'wed', :invalid, 'file' }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end

    it 'Invalid day' do
      expect { subject.download_all_update 'BAD', :json, 'file' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#download_freight_full' do
    expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
    expect(http_client).to receive(:download)
      .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_FULL_DAILY&day=toc-full', 'file')
    subject.download_freight_full 'file'
  end

  describe '#download_freight_update' do
    it 'Valid day' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-mon', 'file')
      subject.download_freight_update 'mon', 'file'
    end

    it 'Invalid day' do
      expect { subject.download_freight_update('BAD', 'file') {} }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#download_toc_full' do
    expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
    expect(http_client).to receive(:download)
      .with('ntrod/CifFileAuthenticate?type=CIF_TT_TOC_FULL_DAILY&day=toc-full', 'file')
    subject.download_toc_full 'TT', 'file'
  end

  describe '#download_toc_update' do
    it 'Valid day' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:download)
        .with('ntrod/CifFileAuthenticate?type=CIF_TT_TOC_UPDATE_DAILY&day=toc-update-wed', 'file')
      subject.download_toc_update 'TT', 'wed', 'file'
    end

    it 'Invalid day' do
      expect { subject.download_toc_update 'TT', 'BAD', 'file' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  describe '#download' do
    it 'Passes credentials and logger to HTTP client' do
      credentials = double RailFeeds::NetworkRail::Credentials
      logger = double Logger
      expect(RailFeeds::NetworkRail::HTTPClient)
        .to receive(:new).with(credentials: credentials, logger: logger)
                         .and_return(http_client)
      expect(http_client).to receive(:download).and_return(reader)
      subject = described_class.new credentials: credentials, logger: logger
      subject.send :download, 'toc', 'mon', :json, 'file'
    end

    it 'CIF format request for non all schedule' do
      expect { subject.send(:download, 'toc', 'mon', :cif, 'file') {} }
        .to raise_error ArgumentError, 'CIF format is only available for the all schedule'
    end
  end

  describe '#fetch_all_full' do
    it 'CIF format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full.CIF.gz')
        .and_yield(reader)
      expect { |a| subject.fetch_all_full(:cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full')
        .and_yield(reader)
      expect { |a| subject.fetch_all_full(:json, &a) }.to yield_with_args(reader)
    end

    it 'Invalid format' do
      expect { subject.fetch_all_full :invalid }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end
  end

  describe '#fetch_all_update' do
    it 'CIF format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon.CIF.gz')
        .and_yield(reader)
      expect { |a| subject.fetch_all_update('mon', :cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-tue')
        .and_yield(reader)
      expect { |a| subject.fetch_all_update('tue', :json, &a) }.to yield_with_args(reader)
    end

    it 'Invalid format' do
      expect { subject.fetch_all_update 'wed', :invalid }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end

    it 'Invalid day' do
      expect { subject.fetch_all_update 'BAD', :json }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#fetch_freight_full' do
    expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
    expect(http_client).to receive(:fetch_unzipped)
      .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_FULL_DAILY&day=toc-full')
      .and_yield(reader)
    expect { |a| subject.fetch_freight_full(&a) }.to yield_with_args(reader)
  end

  describe '#fetch_freight_update' do
    it 'Valid day' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-mon')
        .and_yield(reader)
      expect { |a| subject.fetch_freight_update('mon', &a) }.to yield_with_args(reader)
    end

    it 'Invalid day' do
      expect { subject.fetch_freight_update('BAD') {} }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#fetch_toc_full' do
    expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
    expect(http_client).to receive(:fetch_unzipped)
      .with('ntrod/CifFileAuthenticate?type=CIF_TT_TOC_FULL_DAILY&day=toc-full')
      .and_yield(reader)
    expect { |a| subject.fetch_toc_full('TT', &a) }.to yield_with_args(reader)
  end

  describe '#fetch_toc_update' do
    it 'Valid day' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped)
        .with('ntrod/CifFileAuthenticate?type=CIF_TT_TOC_UPDATE_DAILY&day=toc-update-wed')
        .and_yield(reader)
      expect { |a| subject.fetch_toc_update('TT', 'wed', &a) }.to yield_with_args(reader)
    end

    it 'Invalid day' do
      expect { subject.fetch_toc_update 'TT', 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  describe '#fetch' do
    it 'Passes credentials and logger to HTTP client' do
      credentials = double RailFeeds::NetworkRail::Credentials
      logger = double Logger
      expect(RailFeeds::NetworkRail::HTTPClient)
        .to receive(:new).with(credentials: credentials, logger: logger)
                         .and_return(http_client)
      expect(http_client).to receive(:fetch_unzipped).and_return(reader)
      subject = described_class.new credentials: credentials, logger: logger
      subject.send :fetch, 'toc', 'mon', :json
    end

    it 'CIF format request for non all schedule' do
      expect { subject.send(:fetch, 'toc', 'mon', :cif) {} }
        .to raise_error ArgumentError, 'CIF format is only available for the all schedule'
    end
  end
end
