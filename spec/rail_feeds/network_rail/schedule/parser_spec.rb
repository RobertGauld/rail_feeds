# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Parser do
  let(:on_header_proc) { proc { fail 'Called on_header_proc!' } }
  let(:on_trailer_proc) { proc { fail 'Called on_trailer_proc!' } }
  let(:on_tiploc_insert_proc) { proc { fail 'Called on_tiploc_insert_proc!' } }
  let(:on_tiploc_amend_proc) { proc { fail 'Called on_tiploc_amend_proc!' } }
  let(:on_tiploc_delete_proc) { proc { fail 'Called on_tiploc_delete_proc!' } }
  let(:on_association_new_proc) { proc { fail 'Called on_association_new_proc!' } }
  let(:on_association_revise_proc) { proc { fail 'Called on_association_revise_proc!' } }
  let(:on_association_delete_proc) { proc { fail 'Called on_association_delete_proc!' } }
  let(:on_train_new_proc) { proc { fail 'Called on_train_new_proc!' } }
  let(:on_train_revise_proc) { proc { fail 'Called on_train_revise_proc!' } }
  let(:on_train_delete_proc) { proc { fail 'Called on_train_delete_proc!' } }
  let(:on_comment_proc) { proc { fail 'Called on_comment_proc!' } }
  subject do
    described_class.new(
      on_header: on_header_proc,
      on_trailer: on_trailer_proc,
      on_tiploc_insert: on_tiploc_insert_proc,
      on_tiploc_amend: on_tiploc_amend_proc,
      on_tiploc_delete: on_tiploc_delete_proc,
      on_association_new: on_association_new_proc,
      on_association_revise: on_association_revise_proc,
      on_association_delete: on_association_delete_proc,
      on_train_new: on_train_new_proc,
      on_train_revise: on_train_revise_proc,
      on_train_delete: on_train_delete_proc,
      on_comment: on_comment_proc
    )
  end

  let(:header_line) do
    "HDTPS.UDFROC1.PD1806080806181950DFROC2Q       FA080618080619                    \n"
  end
  let(:comment_line) { "/this is a comment\n" }
  let(:trailer_line) { "ZZ#{' ' * 78}\n" }
  let(:tiploc_insert_line) { "TI#{' ' * 78}\n" }
  let(:tiploc_amend_line) { "TA#{' ' * 78}\n" }
  let(:tiploc_delete_line) { "TD#{' ' * 78}\n" }
  let(:association_new_line) do
    "AAN            0102030405060101010                                             P\n"
  end
  let(:association_revise_line) do
    "AAR            0102030405060101010                                             P\n"
  end
  let(:association_delete_line) do
    "AAD            0102030405060101010                                             P\n"
  end
  let(:train_new_lines) do
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
  let(:train_revise_lines) do
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
  let(:train_delete_line) { format('%-79.79s', 'BSD      010203040506') + "P\n" }

  let(:smallest_file) { StringIO.new header_line + trailer_line }

  describe '#parse_line' do
    it 'Calls on_header proc' do
      expect(on_header_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Header)
      )
      subject.parse_cif_line header_line
    end

    it 'Calls on_trailer proc' do
      expect(on_trailer_proc).to receive(:call)
        .with(instance_of(RailFeeds::NetworkRail::Schedule::Parser))
      subject.parse_cif_line trailer_line
    end

    it 'Calls on_tiploc_insert proc' do
      expect(on_tiploc_insert_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Tiploc)
      )
      subject.parse_cif_line tiploc_insert_line
    end

    it 'Calls on_tiploc_amend proc' do
      expect(on_tiploc_amend_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(String),
        instance_of(RailFeeds::NetworkRail::Schedule::Tiploc)
      )
      subject.parse_cif_line tiploc_amend_line
    end

    it 'Calls on_tiploc_delete proc' do
      expect(on_tiploc_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(String)
      )
      subject.parse_cif_line tiploc_delete_line
    end

    it 'Calls on_association_new proc' do
      expect(on_association_new_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_cif_line association_new_line
    end

    it 'Calls on_association_revise proc' do
      expect(on_association_revise_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_cif_line association_revise_line
    end

    it 'Calls on_association_delete proc' do
      expect(on_association_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Association)
      )
      subject.parse_cif_line association_delete_line
    end

    it 'Calls on_train_delete proc' do
      expect(on_train_delete_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Train)
      )
      subject.parse_cif_line train_delete_line
    end

    it 'Calls on_comment proc' do
      expect(on_comment_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        'this is a comment'
      )
      subject.parse_cif_line comment_line
    end

    it 'Logs and ignores bad line' do
      logger = double Logger
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:debug)
      allow(logger).to receive(:info)
      expect(logger).to receive(:error).with('Can\'t understand line: "XXXX"')
      expect { subject.parse_cif_line "XXXX\n" }.to_not raise_error
    end
  end

  describe '#parse_cif_file' do
    it 'Calls on_train_new proc' do
      allow(on_trailer_proc).to receive(:call)
      expect(on_train_new_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Train)
      ).twice
      subject.parse_cif_file StringIO.new(train_new_lines + trailer_line)
    end

    it 'Calls on_train_revise proc' do
      allow(on_trailer_proc).to receive(:call)
      expect(on_train_revise_proc).to receive(:call).with(
        instance_of(RailFeeds::NetworkRail::Schedule::Parser),
        instance_of(RailFeeds::NetworkRail::Schedule::Train)
      ).twice
      subject.parse_cif_file StringIO.new(train_revise_lines + trailer_line)
    end

    it 'Created trains have locations' do
      trains = []
      train_proc = proc { |_parser, train| trains.push train }
      subject = described_class.new(on_train_new: train_proc)
      subject.parse_cif_file StringIO.new(header_line + train_new_lines + trailer_line)
      expect(trains.map { |t| t.journey.count }).to eq [3, 2]
    end

    it 'File is incomplete' do
      incomplete_file = StringIO.new header_line
      expect(on_header_proc).to receive(:call)
      expect { subject.parse_cif_file incomplete_file }
        .to raise_error RuntimeError, "File is incomplete. #{incomplete_file.inspect}"
    end

    it '#stop_parsing' do
      subject = described_class.new(
        on_header: proc { |parser, _header| parser.stop_parsing },
        on_trailer: on_trailer_proc
      )
      expect(on_trailer_proc).to_not receive(:call)
      subject.parse_cif_file smallest_file
    end
  end
end
