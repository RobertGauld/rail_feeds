# frozen_string_literal: true

describe RailFeeds::NetworkRail::SMART do
  let :json do
    '{"BERTHDATA":[{"ROUTE":"2","STANME":"NEWBRGH","BERTHOFFSET":"0","EVENT":"B","COMM' \
    'ENT":"17/02/2008","PLATFORM":"5","TD":"EA","FROMBERTH":"B674","TOBERTH":"B672","S' \
    'TANOX":"03211","STEPTYPE":"B","TOLINE":"F","FROMLINE":"S"},{"ROUTE":"","STANME":"' \
    'DMOORCTRL","BERTHOFFSET":"+60","EVENT":"C","COMMENT":"Migrated on 8/6/2005","PLAT' \
    'FORM":"","TD":"A2","FROMBERTH":"0759","TOBERTH":"0808","STANOX":"89748","STEPTYPE' \
    '":"","TOLINE":"","FROMLINE":""},{"ROUTE":"","STANME":"","BERTHOFFSET":"","EVENT":' \
    '"","COMMENT":"","PLATFORM":"","TD":"","FROMBERTH":"","TOBERTH":"","STANOX":"","ST' \
    'EPTYPE":"","TOLINE":"","FROMLINE":""}]}'
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
        .with('ntrod/SupportingFileAuthenticate?type=SMART', 'file')
      described_class.download 'file'
    end

    it 'Using passed credentials' do
      credentials = double RailFeeds::NetworkRail::Credentials
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new)
        .with(credentials: credentials).and_return(http_client)
      expect(http_client).to receive(:download)
      described_class.download 'file', credentials
    end
  end

  describe '::fetch' do
    let(:http_client) { double RailFeeds::NetworkRail::HTTPClient }
    let(:temp_file) { double Tempfile }

    it 'Using default credentials' do
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new)
        .with(credentials: RailFeeds::NetworkRail::Credentials).and_return(http_client)
      expect(http_client).to receive(:fetch)
        .with('ntrod/SupportingFileAuthenticate?type=SMART').and_return(temp_file)
      expect(described_class.fetch).to eq temp_file
    end

    it 'Using passed credentials' do
      credentials = double RailFeeds::NetworkRail::Credentials
      expect(RailFeeds::NetworkRail::HTTPClient).to receive(:new)
        .with(credentials: credentials).and_return(http_client)
      expect(http_client).to receive(:fetch).and_return(temp_file)
      expect(described_class.fetch(credentials)).to eq temp_file
    end
  end

  describe '::load_file' do
    it 'json file' do
      expect(Zlib::GzipReader).to receive(:open).with('filename') { fail Zlib::GzipFile::Error }
      expect(File).to receive(:read).with('filename').and_return(json)
      data = described_class.load_file('filename')
      expect(data[0].td_area).to eq 'EA'
      expect(data[0].from_berth).to eq 'B674'
      expect(data[0].to_berth).to eq 'B672'
      expect(data[0].from_line).to eq 'S'
      expect(data[0].to_line).to eq 'F'
      expect(data[0].trust_offset).to eq 0
      expect(data[0].platform).to eq '5'
      expect(data[0].event_type).to eq :depart
      expect(data[0].event_direction).to eq :up
      expect(data[0].route).to eq '2'
      expect(data[0].stanox).to eq 3211
      expect(data[0].stanox_name).to eq 'NEWBRGH'
      expect(data[0].step_type).to eq :between
      expect(data[0].comment).to eq '17/02/2008'
      expect(data[1].trust_offset).to eq 60
      expect(data[2].td_area).to be_nil
      expect(data[2].from_berth).to be_nil
      expect(data[2].to_berth).to be_nil
      expect(data[2].from_line).to be_nil
      expect(data[2].to_line).to be_nil
      expect(data[2].trust_offset).to eq 0
      expect(data[2].platform).to be_nil
      expect(data[2].event_type).to be_nil
      expect(data[2].event_direction).to be_nil
      expect(data[2].route).to be_nil
      expect(data[2].stanox).to be_nil
      expect(data[2].stanox_name).to be_nil
      expect(data[2].step_type).to be_nil
      expect(data[2].comment).to be_nil
    end

    it 'json.gz file' do
      expect(Zlib::GzipReader).to receive(:open).with('filename')
                                                .and_yield(StringIO.new(json))
      expect(described_class.load_file('filename').count).to eq 3
    end
  end

  it '::build_berths' do
    # For the trackplan:
    #   Down ---> Up
    # --A----B----C--
    #     \--D-->-E--
    #      \-F-<-/
    # And therefore the steps:
    steps = [
      RailFeeds::NetworkRail::SMART::Step.new('area', 'A', 'B', :between, :up),   # 0
      RailFeeds::NetworkRail::SMART::Step.new('area', 'A', 'D', :between, :up),   # 1
      RailFeeds::NetworkRail::SMART::Step.new('area', 'A', 'F', :between, :up),   # 2
      RailFeeds::NetworkRail::SMART::Step.new('area', 'B', 'C', :between, :up),   # 3
      RailFeeds::NetworkRail::SMART::Step.new('area', 'D', 'E', :between, :up),   # 4
      RailFeeds::NetworkRail::SMART::Step.new('area', 'B', 'A', :between, :down), # 5
      RailFeeds::NetworkRail::SMART::Step.new('area', 'D', 'A', :between, :down), # 6
      RailFeeds::NetworkRail::SMART::Step.new('area', 'F', 'A', :between, :down), # 7
      RailFeeds::NetworkRail::SMART::Step.new('area', 'C', 'B', :between, :down), # 8
      RailFeeds::NetworkRail::SMART::Step.new('area', 'E', 'F', :between, :down)  # 9
    ]

    berths = described_class.build_berths(steps)['area']
    expect(berths['A'].id).to eq 'A'
    expect(berths['A'].up_steps).to match_array steps.values_at(0, 1, 2, 5, 6, 7)
    expect(berths['A'].down_steps).to match_array []
    expect(berths['A'].up_berths).to match_array ['B', 'D', 'F']
    expect(berths['A'].down_berths).to match_array []
    expect(berths['B'].id).to eq 'B'
    expect(berths['B'].up_steps).to match_array steps.values_at(3, 8)
    expect(berths['B'].down_steps).to match_array steps.values_at(5, 0)
    expect(berths['B'].up_berths).to match_array ['C']
    expect(berths['B'].down_berths).to match_array ['A']
    expect(berths['C'].id).to eq 'C'
    expect(berths['C'].up_steps).to match_array []
    expect(berths['C'].down_steps).to match_array steps.values_at(8, 3)
    expect(berths['C'].up_berths).to match_array []
    expect(berths['C'].down_berths).to match_array ['B']
    expect(berths['D'].id).to eq 'D'
    expect(berths['D'].up_steps).to match_array steps.values_at(4)
    expect(berths['D'].down_steps).to match_array steps.values_at(6, 1)
    expect(berths['D'].up_berths).to match_array ['E']
    expect(berths['D'].down_berths).to match_array ['A']
    expect(berths['E'].id).to eq 'E'
    expect(berths['E'].up_steps).to match_array []
    expect(berths['E'].down_steps).to match_array steps.values_at(4, 9)
    expect(berths['E'].up_berths).to match_array []
    expect(berths['E'].down_berths).to match_array ['F']
    expect(berths['F'].id).to eq 'F'
    expect(berths['F'].up_steps).to match_array steps.values_at(9)
    expect(berths['F'].down_steps).to match_array steps.values_at(2, 7)
    expect(berths['F'].up_berths).to match_array []
    expect(berths['F'].down_berths).to match_array ['A']
  end

  it '::fetch_data' do
    expect(RailFeeds::NetworkRail::HTTPClient)
      .to receive(:new).with(credentials: RailFeeds::NetworkRail::Credentials)
                       .and_return(http_client)
    expect(http_client).to receive(:fetch_unzipped)
      .with('ntrod/SupportingFileAuthenticate?type=SMART')
      .and_yield(reader)
    expect(reader).to receive(:read).and_return(json)
    expect(described_class.fetch_data.count).to eq 3
  end

  describe 'Helping methods' do
    it '::event_type' do
      expect(described_class.send(:event_type, 'A')).to eq :arrive
      expect(described_class.send(:event_type, 'B')).to eq :depart
      expect(described_class.send(:event_type, 'C')).to eq :arrive
      expect(described_class.send(:event_type, 'D')).to eq :depart
      expect(described_class.send(:event_type, 'Z')).to be_nil
    end

    it '::event_direction' do
      expect(described_class.send(:event_direction, 'A')).to eq :up
      expect(described_class.send(:event_direction, 'B')).to eq :up
      expect(described_class.send(:event_direction, 'C')).to eq :down
      expect(described_class.send(:event_direction, 'D')).to eq :down
      expect(described_class.send(:event_direction, 'Z')).to be_nil
    end

    it '::step_type' do
      expect(described_class.send(:step_type, 'B')).to eq :between
      expect(described_class.send(:step_type, 'F')).to eq :from
      expect(described_class.send(:step_type, 'T')).to eq :to
      expect(described_class.send(:step_type, 'D')).to eq :intermediate_first
      expect(described_class.send(:step_type, 'C')).to eq :clearout
      expect(described_class.send(:step_type, 'I')).to eq :interpose
      expect(described_class.send(:step_type, 'E')).to eq :intermediate
      expect(described_class.send(:step_type, 'Z')).to be_nil
    end
  end
end
