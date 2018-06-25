# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Fetcher do
  let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
  let(:reader) { double Zlib::GzipReader }

  describe '#fetch_all_full' do
    it 'CIF format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_FULL_DAILY&day=toc-full', :cif)
        .and_yield(reader)
      expect { |a| subject.fetch_all_full(:cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_FULL_DAILY&day=toc-full', :json)
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
        .with('type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon', :cif)
        .and_yield(reader)
      expect { |a| subject.fetch_all_update('mon', :cif, &a) }.to yield_with_args(reader)
    end

    it 'JSON format' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_ALL_UPDATE_DAILY&day=toc-update-tue', :json)
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
      .with('type=CIF_FREIGHT_FULL_DAILY&day=toc-full', :json)
      .and_yield(reader)
    expect { |a| subject.fetch_freight_full(&a) }.to yield_with_args(reader)
  end

  describe '#fetch_freight_update' do
    it 'Valid day' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-tue', :json)
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
      .with('type=CIF_TT_TOC_FULL_DAILY&day=toc-full', :json)
      .and_yield(reader)
    expect { |a| subject.fetch_toc_full('TT', &a) }.to yield_with_args(reader)
  end

  describe '#fetch_toc_update' do
    it 'Valid day' do
      expect(subject).to receive(:fetch)
        .with('type=CIF_TT_TOC_UPDATE_DAILY&day=toc-update-wed', :json)
        .and_yield(reader)
      expect { |a| subject.fetch_toc_update('TT', 'wed', &a) }.to yield_with_args(reader)
    end

    it 'Invalid day' do
      expect { subject.fetch_toc_update 'TT', 'BAD' }
        .to raise_error ArgumentError, 'day is invalid'
    end
  end

  describe '#fetch_all' do
    it 'CIF format' do
      full_file = StringIO.new "HDTPS.UDFROC1.PD1806151506181950DFROC2X       FA150618150619\n"
      first_update = Date.new(2018, 6, 16)
      expect(subject).to receive(:fetch_all_full).with(:cif).and_yield(full_file)
      expect(subject).to receive(:fetch_all_updates).with(first_update, :cif)
      expect { |a| subject.fetch_all(:cif, &a) }.to yield_with_args(full_file)
    end

    it 'JSON format' do
      full_file = StringIO.new '{"JsonTimetableV1":{"timestamp":1529708668,"Metadata":{"sequence":2193}}}' + "\n"
      first_update = Date.new(2018, 6, 16)
      expect(subject).to receive(:fetch_all_full).with(:json).and_yield(full_file)
      expect(subject).to receive(:fetch_all_updates).with(first_update, :json)
      expect { |a| subject.fetch_all(:json, &a) }.to yield_with_args(full_file)
    end
  end

  describe '#fetch_all_updates' do
    before(:each) { Timecop.freeze 2018, 6, 19, 4, 0 }
    # This time is after the CIF is available but before the JSON is.

    it 'CIF format' do
      update_sat = StringIO.new "HDTPS.UDFROC1.PD1806161606181950DFROC1BDFROC1AFA160618160619\n"
      update_sun = StringIO.new "HDTPS.UDFROC1.PD1806171706181950DFROC1CDFROC1BFA170618170619\n"
      update_mon = StringIO.new "HDTPS.UDFROC1.PD1806181806181950DFROC1DDFROC1CFA180618180619\n"
      expect(subject).to receive(:fetch_all_update).with('sat', :cif).and_yield(update_sat)
      expect(subject).to receive(:fetch_all_update).with('sun', :cif).and_yield(update_sun)
      expect(subject).to receive(:fetch_all_update).with('mon', :cif).and_yield(update_mon)

      first_update = Date.new 2018, 6, 16
      expect { |b| subject.fetch_all_updates first_update, :cif, &b }
        .to yield_successive_args(update_sat, update_sun, update_mon)
    end

    it 'JSON format' do
      update_sat = StringIO.new '{"JsonTimetableV1":{"timestamp":1529190644,"Metadata":{"sequence":2193}}}' + "\n"
      update_sun = StringIO.new '{"JsonTimetableV1":{"timestamp":1529277044,"Metadata":{"sequence":2194}}}' + "\n"
      expect(subject).to receive(:fetch_all_update).with('sat', :json).and_yield(update_sat)
      expect(subject).to receive(:fetch_all_update).with('sun', :json).and_yield(update_sun)
      expect(subject).to_not receive(:fetch_all_update).with('mon', :json)

      first_update = Date.new 2018, 6, 16
      expect { |b| subject.fetch_all_updates first_update, :json, &b }
        .to yield_successive_args(update_sat, update_sun)
    end

    it 'first_update is over a week ago' do
      expect { subject.fetch_all_updates(Date.new(2018, 6, 11)) }
        .to raise_error ArgumentError, 'Updates are only available from the last 7 days.'
    end

    it 'first_update is in the future' do
      expect { subject.fetch_all_updates(Date.new(2018, 6, 20)) }
        .to raise_error ArgumentError, 'Can\'t get updates from the future.'
    end

    it 'Handles getting a file who\'s date doesn\'t match expectation' do
      update_sun = StringIO.new "HDTPS.UDFROC1.PD1806171706181950DFROC1CDFROC1BFA170618170619\n"
      update_mon = StringIO.new "HDTPS.UDFROC1.PD1106181106181950DFROC1HDFROC1GFA110618110619\n"
      expect(subject).to receive(:fetch_all_update).with('sun', :cif).and_yield(update_sun)
      expect(subject).to receive(:fetch_all_update).with('mon', :cif).and_yield(update_mon)

      first_update = Date.new 2018, 6, 17
      expect { |b| subject.fetch_all_updates first_update, :cif, &b }
        .to yield_successive_args(update_sun)
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
        subject.send :fetch, 'query=string', :json
      end

      it 'CIF format' do
        expect(RailFeeds::NetworkRail::HTTPClient)
          .to receive(:new)
          .and_return(http_client)
        expect(http_client).to receive(:get_unzipped)
          .with('ntrod/CifFileAuthenticate?query=string.CIF.gz')
          .and_return(reader)
        subject.send :fetch, 'query=string', :cif
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
      subject.send :fetch, '', :cif
    end

    it 'Yields file contents' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:get_unzipped).and_yield(reader)
      expect { |a| subject.send(:fetch, '', :cif, &a) }.to yield_with_args(reader)
    end
  end
end
