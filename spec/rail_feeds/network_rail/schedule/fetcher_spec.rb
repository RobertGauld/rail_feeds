# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Fetcher do
  let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
  let(:reader) { double Zlib::GzipReader }

  describe '#fetch_all_full' do
    it 'CIF format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_FULL_DAILY&day=toc-full', format: :cif)
        .and_yield(reader)
      expect { |a| subject.fetch_all_full(:cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_FULL_DAILY&day=toc-full', format: :json)
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
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon', format: :cif)
        .and_yield(reader)
      expect { |a| subject.fetch_all_update('mon', :cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_UPDATE_DAILY&day=toc-update-tue', format: :json)
        .and_yield(reader)
      expect { |a| subject.fetch_all_update('tue', :json, &a) }.to yield_with_args(reader)
    end

    it 'Invalid format' do
      expect { subject.fetch_all_update 'mon', :invalid }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end

    it 'Invalid day' do
      expect { subject.fetch_all_update 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#fetch_freight_full' do
    expect(subject).to receive(:fetch)
      .with('type=CIF_FREIGHT_FULL_DAILY&day=toc-full')
      .and_yield(reader)
    expect { |a| subject.fetch_freight_full(&a) }.to yield_with_args(reader)
  end

  describe '#fetch_freight_update' do
    it 'Valid day' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-tue')
        .and_yield(reader)
      expect { |a| subject.fetch_freight_update('tue', &a) }.to yield_with_args(reader)
    end

    it 'Invalid day' do
      expect { subject.fetch_freight_update 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  it '#fetch_toc_full' do
    expect(subject).to receive(:fetch)
      .with('type=CIF_TT_TOC_FULL_DAILY&day=toc-full')
      .and_yield(reader)
    expect { |a| subject.fetch_toc_full('TT', &a) }.to yield_with_args(reader)
  end

  describe '#fetch_toc_update' do
    it 'Valid day' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_TT_TOC_UPDATE_DAILY&day=toc-update-wed')
        .and_yield(reader)
      expect { |a| subject.fetch_toc_update('TT', 'wed', &a) }.to yield_with_args(reader)
    end

    it 'Invalid day' do
      expect { subject.fetch_toc_update 'TT', 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  describe '#fetch' do
    describe 'Generates correct path' do
      it 'JSON format' do
        expect(RailFeeds::NetworkRail::HTTPClient)
          .to receive(:new)
          .and_return(http_client)
        expect(http_client).to receive(:get_unzipped)
          .with('ntrod/CifFileAuthenticate?query=string')
          .and_return(reader)
        subject.send :fetch, 'query=string', format: :json
      end

      it 'CIF format' do
        expect(RailFeeds::NetworkRail::HTTPClient)
          .to receive(:new)
          .and_return(http_client)
        expect(http_client).to receive(:get_unzipped)
          .with('ntrod/CifFileAuthenticate?query=string.CIF.gz')
          .and_return(reader)
        subject.send :fetch, 'query=string', format: :cif
      end
    end

    it 'Passes credentials and logger to HTTP client' do
      credentials = double RailFeeds::NetworkRail::Credentials
      logger = double Logger
      expect(RailFeeds::NetworkRail::HTTPClient)
        .to receive(:new).with(credentials: credentials, logger: logger)
                         .and_return(http_client)
      expect(http_client).to receive(:get_unzipped).and_return(reader)
      subject = described_class.new credentials: credentials, logger: logger
      subject.send :fetch, ''
    end

    it 'Yields file contents' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:get_unzipped).and_yield(reader)
      expect { |a| subject.send(:fetch, '', &a) }.to yield_with_args(reader)
    end
  end
end
