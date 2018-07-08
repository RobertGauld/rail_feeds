# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Parser::JSON do
  let(:on_header_proc) { proc { fail 'Called on_header_proc!' } }
  let(:on_trailer_proc) { proc { fail 'Called on_trailer_proc!' } }
  let(:on_tiploc_create_proc) { proc { fail 'Called on_tiploc_create_proc!' } }
  let(:on_tiploc_update_proc) { proc { fail 'Called on_tiploc_update_proc!' } }
  let(:on_tiploc_delete_proc) { proc { fail 'Called on_tiploc_delete_proc!' } }
  let(:on_association_create_proc) { proc { fail 'Called on_association_create_proc!' } }
  let(:on_association_update_proc) { proc { fail 'Called on_association_update_proc!' } }
  let(:on_association_delete_proc) { proc { fail 'Called on_association_delete_proc!' } }
  let(:on_train_schedule_create_proc) { proc { fail 'Called on_train_schedule_create_proc!' } }
  let(:on_train_schedule_update_proc) { proc { fail 'Called on_train_schedule_update_proc!' } }
  let(:on_train_schedule_delete_proc) { proc { fail 'Called on_train_schedule_delete_proc!' } }
  let(:on_comment_proc) { proc { fail 'Called on_comment_proc!' } }
  subject do
    described_class.new(
      on_header: on_header_proc,
      on_trailer: on_trailer_proc,
      on_tiploc_create: on_tiploc_create_proc,
      on_tiploc_update: on_tiploc_update_proc,
      on_tiploc_delete: on_tiploc_delete_proc,
      on_association_create: on_association_create_proc,
      on_association_update: on_association_update_proc,
      on_association_delete: on_association_delete_proc,
      on_train_schedule_create: on_train_schedule_create_proc,
      on_train_schedule_update: on_train_schedule_update_proc,
      on_train_schedule_delete: on_train_schedule_delete_proc,
      on_comment: on_comment_proc
    )
  end

  describe '#parse_line' do
    it 'Calls on_header proc' do
      line = '{"JsonTimetableV1":{"classification":"public","timestamp":1530659402,' \
             '"owner":"Network Rail","Sender":{"organisation":"Rockshore",' \
             '"application":"NTROD","component":"SCHEDULE"},"Metadata":{"type":' \
             '"full","sequence":2211}}}'
      expect(on_header_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::Header::JSON)
      )
      subject.parse_line line
    end

    it 'Calls on_trailer proc' do
      line = '{"EOF":true}'
      expect(on_trailer_proc).to receive(:call)
        .with(instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON))
      subject.parse_line line
    end

    it 'Calls on_tiploc_create proc' do
      line = '{"TiplocV1":{"transaction_type":"Create","tiploc_code":"SCAREXS","nalco"' \
             ':"818502","stanox":"16203","crs_code":null,"description":null,' \
             '"tps_description":"SCARBOROUGH EXCURSION SDGS"}}'
      expect(on_tiploc_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::Tiploc)
      )
      subject.parse_line line
    end

    it 'Calls on_tiploc_delete proc' do
      line = '{"TiplocV1":{"transaction_type":"Delete","tiploc_code":"SCAREXS","nalco"' \
             ':"818502","stanox":"16203","crs_code":null,"description":null,' \
             '"tps_description":"SCARBOROUGH EXCURSION SDGS"}}'
      expect(on_tiploc_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(String)
      )
      subject.parse_line line
    end

    it 'Unknown tiploc action' do
      logger = double Logger
      line = '{"TiplocV1":{"transaction_type":"Unknown"}}'
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error)
        .with("Don't know how to \"Unknown\" a Tiploc: #{line}")
      expect { subject.parse_line line }.to_not raise_error
    end

    it 'Calls on_association_create proc' do
      line = '{"JsonAssociationV1":{"transaction_type":"Create","main_train_uid":' \
             '"C66471","assoc_train_uid":"C65170","assoc_start_date":' \
             '"2018-08-05T00:00:00Z","assoc_end_date":"2018-09-02T00:00:00Z",' \
             '"assoc_days":"0000001","category":"NP","date_indicator":"S","location"' \
             ':"NTNG","base_location_suffix":null,"assoc_location_suffix":null,' \
             '"diagram_type":"T","CIF_stp_indicator":"P"}}'
      expect(on_association_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_line line
    end

    it 'Calls on_association_delete proc' do
      line = '{"JsonAssociationV1":{"transaction_type":"Delete","main_train_uid":' \
             '"L10610","assoc_train_uid":"L10543","assoc_start_date":' \
             '"2018-07-01T00:00:00Z","location":"STPANCI","base_location_suffix":null' \
             ',"diagram_type":"T","CIF_stp_indicator":"C"}}'
      expect(on_association_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_line line
    end

    it 'Unknown association action' do
      logger = double Logger
      line = '{"JsonAssociationV1":{"transaction_type":"Unknown"}}'
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error)
        .with("Don't know how to \"Unknown\" an Association: #{line}")
      expect { subject.parse_line line }.to_not raise_error
    end


    it 'Calls on_train_delete proc' do
      expect(on_train_schedule_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::TrainSchedule)
      )
      line = File.read(File.join(RSPEC_FIXTURES, 'network_rail', 'schedule', 'parser', 'train_delete.json'))
      subject.parse_line line
    end

    it 'Calls on_train_create proc' do
      allow(on_trailer_proc).to receive(:call)
      expect(on_train_schedule_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::JSON),
        instance_of(RailFeeds::NetworkRail::Schedule::TrainSchedule)
      )
      line = File.read(File.join(RSPEC_FIXTURES, 'network_rail', 'schedule', 'parser', 'train_create.json'))
      subject.parse_line line
    end

    it 'Unknown train action' do
      logger = double Logger
      line = '{"JsonScheduleV1":{"transaction_type":"Unknown"}}'
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error)
        .with("Don't know how to \"Unknown\" a Train Schedule: #{line}")
      expect { subject.parse_line line }.to_not raise_error
    end

    it 'Created trains have locations' do
      trains = []
      train_proc = proc { |_parser, train| trains.push train }
      subject = described_class.new(on_train_schedule_create: train_proc)
      line = File.read(File.join(RSPEC_FIXTURES, 'network_rail', 'schedule', 'parser', 'train_create.json'))
      subject.parse_line String.new line
      expect(trains.map { |t| t.journey.count }).to eq [8]
    end

    it 'Logs and ignores bad line' do
      logger = double Logger
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error).with('Can\'t understand line: ["XXX"]')
      expect { subject.parse_line '["XXX"]' }.to_not raise_error
    end
  end
end
