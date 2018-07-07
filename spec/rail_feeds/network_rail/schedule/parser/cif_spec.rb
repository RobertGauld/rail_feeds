# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Parser::CIF do
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

  let(:header_line) do
    "HDTPS.UDFROC1.PD1806080806181950DFROC2Q       FA080618080619                    \n"
  end
  let(:comment_line) { "/this is a comment\n" }
  let(:trailer_line) { "ZZ#{' ' * 78}\n" }
  let(:tiploc_create_line) { "TI#{' ' * 78}\n" }
  let(:tiploc_update_line) { "TA#{' ' * 78}\n" }
  let(:tiploc_delete_line) { "TD#{' ' * 78}\n" }
  let(:association_create_line) do
    "AAN            0102030405060101010                                             P\n"
  end
  let(:association_update_line) do
    "AAR            0102030405060101010                                             P\n"
  end
  let(:association_delete_line) do
    "AAD            0102030405060101010                                             P\n"
  end
  let(:train_schedule_create_lines) do
    [
      format('%-79s', 'BSN      010203040506') + 'P',
      format('%-80s', 'BX'),
      format('%-80s', 'LO'),
      format('%-80s', 'LI'),
      format('%-80s', 'LT'),
      format('%-79s', 'BSN      020304070809') + 'P',
      format('%-80s', 'BX'),
      format('%-80s', 'LO'),
      format('%-80s', 'LT')
    ].join("\n") + "\n"
  end
  let(:train_schedule_update_lines) do
    [
      format('%-79s', 'BSR      010203040506') + 'P',
      format('%-80s', 'BX'),
      format('%-80s', 'LO'),
      format('%-80s', 'LI'),
      format('%-80s', 'LT'),
      format('%-79s', 'BSR      020304070809') + 'P',
      format('%-80s', 'BX'),
      format('%-80s', 'LO'),
      format('%-80s', 'LT')
    ].join("\n") + "\n"
  end
  let(:train_schedule_delete_line) { format('%-79.79s', 'BSD      010203040506') + "P\n" }

  let(:smallest_file) { StringIO.new header_line + trailer_line }

  describe '#parse_line' do
    it 'Calls on_header proc' do
      expect(on_header_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::Header::CIF)
      )
      subject.parse_line header_line
    end

    it 'Calls on_trailer proc' do
      expect(on_trailer_proc).to receive(:call)
        .with(instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF))
      subject.parse_line trailer_line
    end

    it 'Calls on_tiploc_create proc' do
      expect(on_tiploc_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::Tiploc)
      )
      subject.parse_line tiploc_create_line
    end

    it 'Calls on_tiploc_update proc' do
      expect(on_tiploc_update_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(String),
        instance_of(RailFeeds::NetworkRail::Schedule::Tiploc)
      )
      subject.parse_line tiploc_update_line
    end

    it 'Calls on_tiploc_delete proc' do
      expect(on_tiploc_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(String)
      )
      subject.parse_line tiploc_delete_line
    end

    it 'Calls on_association_create proc' do
      expect(on_association_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_line association_create_line
    end

    it 'Calls on_association_update proc' do
      expect(on_association_update_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_line association_update_line
    end

    it 'Calls on_association_delete proc' do
      expect(on_association_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_line association_delete_line
    end

    it 'Calls on_train_delete proc' do
      expect(on_train_schedule_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::TrainSchedule)
      )
      subject.parse_line train_schedule_delete_line
    end

    it 'Calls on_comment proc' do
      expect(on_comment_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        'this is a comment'
      )
      subject.parse_line comment_line
    end

    it 'Logs and ignores bad line' do
      logger = double Logger
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error).with('Can\'t understand line: "XXXX"')
      expect { subject.parse_line "XXXX\n" }.to_not raise_error
    end
  end

  describe '#parse_file' do
    it 'Calls on_train_create proc' do
      allow(on_trailer_proc).to receive(:call)
      expect(on_train_schedule_create_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::TrainSchedule)
      ).twice
      subject.parse_file StringIO.new(train_schedule_create_lines + trailer_line)
    end

    it 'Calls on_train_update proc' do
      allow(on_trailer_proc).to receive(:call)
      expect(on_train_schedule_update_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser::CIF),
        instance_of(RailFeeds::NetworkRail::Schedule::TrainSchedule)
      ).twice
      subject.parse_file StringIO.new(train_schedule_update_lines + trailer_line)
    end

    it 'Created trains have locations' do
      trains = []
      train_proc = proc { |_parser, train| trains.push train }
      subject = described_class.new(on_train_schedule_create: train_proc)
      subject.parse_file StringIO.new(header_line + train_schedule_create_lines + trailer_line)
      expect(trains.map { |t| t.journey.count }).to eq [3, 2]
    end
  end
end
