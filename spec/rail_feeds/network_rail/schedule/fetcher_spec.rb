# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Fetcher do
  let(:logger) { Logger.new(IO::NULL) }

  describe '#fetch' do
    let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
    let(:reader) { double Zlib::GzipReader }

    before :each do
      allow(reader).to receive(:each_line)
    end

    it 'Fails on invalid format' do
      expect { subject.fetch :full, format: :invalid }
        .to raise_error ArgumentError, 'format must be either :json or :cif'
    end

    it 'Fails on invalid day' do
      expect { subject.fetch :update, day: 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end

    it 'Passes credentials and logger to HTTP client' do
      credentials = double RailFeeds::NetworkRail::Credentials
      expect(RailFeeds::NetworkRail::HTTPClient)
        .to receive(:new).with(credentials: credentials, logger: logger)
                         .and_return(http_client)
      expect(http_client).to receive(:get_unzipped).and_return(reader)
      subject = described_class.new credentials: credentials, logger: logger
      subject.fetch :full
    end

    describe 'Requests correct path' do
      before :each do
        expect(RailFeeds::NetworkRail::HTTPClient)
          .to receive(:new).and_return(http_client)
      end

      describe 'CIF format' do
        it 'Full schedule' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full.CIF.gz')
            .and_return(reader)
          expect(subject.fetch(:full, format: :cif)).to eq reader
        end

        it 'Full schedule updates' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon.CIF.gz')
            .and_return(reader)
          expect(subject.fetch(:update, day: 'mon', format: :cif)).to eq reader
        end
      end

      describe 'JSON format' do
        it 'Full schedule' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full')
            .and_return(reader)
          expect(subject.fetch(:full, format: :json)).to eq reader
        end

        it 'Full schedule updates' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon')
            .and_return(reader)
          expect(subject.fetch(:update, day: 'mon', format: :json)).to eq reader
        end

        it 'Freight schedule' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_FULL_DAILY&day=toc-full')
            .and_return(reader)
          expect(subject.fetch(:full, toc: 'FREIGHT')).to eq reader
        end

        it 'Freight schedule updates' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-mon')
            .and_return(reader)
          expect(subject.fetch(:update, day: 'mon', toc: 'FREIGHT')).to eq reader
        end

        it 'TOC schedule' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ZZ_TOC_FULL_DAILY&day=toc-full')
            .and_return(reader)
          expect(subject.fetch(:full, toc: 'ZZ')).to eq reader
        end

        it 'TOC schedule updates' do
          expect(http_client)
            .to receive(:get_unzipped)
            .with('ntrod/CifFileAuthenticate?type=CIF_ZZ_TOC_UPDATE_DAILY&day=toc-update-mon')
            .and_return(reader)
          expect(subject.fetch(:update, day: 'mon', toc: 'ZZ')).to eq reader
        end
      end
    end
  end

  describe 'Delegating methods' do
    it '#fetch_all_full' do
      expect(subject).to receive(:fetch)
        .with(:full, format: :format).and_return(:done)
      expect(subject.fetch_all_full(:format)).to eq :done
    end

    it '#fetch_all_update' do
      expect(subject).to receive(:fetch)
        .with(:update, format: :format, day: :day).and_return(:done)
      expect(subject.fetch_all_update(:day, :format)).to eq :done
    end

    it '#fetch_freight_full' do
      expect(subject).to receive(:fetch)
        .with(:full, toc: 'FREIGHT').and_return(:done)
      expect(subject.fetch_freight_full).to eq :done
    end

    it '#fetch_freight_update' do
      expect(subject).to receive(:fetch)
        .with(:update, toc: 'FREIGHT', day: :day).and_return(:done)
      expect(subject.fetch_freight_update(:day)).to eq :done
    end

    it '#fetch_toc_full' do
      expect(subject).to receive(:fetch)
        .with(:full, toc: :toc).and_return(:done)
      expect(subject.fetch_toc_full(:toc)).to eq :done
    end

    it '#fetch_toc_update' do
      expect(subject).to receive(:fetch)
        .with(:update, toc: :toc, day: :day).and_return(:done)
      expect(subject.fetch_toc_update(:toc, :day)).to eq :done
    end
  end
end
