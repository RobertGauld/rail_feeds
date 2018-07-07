# frozen_string_literal: true

describe RailFeeds::NetworkRail::Schedule::Parser do
  describe '#parse_file' do
    let(:file_content) { StringIO.new "1\n2\nEND\n" }

    it 'Calls parse_line for each line' do
      expect(subject).to receive(:parse_line).with("1\n")
      expect(subject).to receive(:parse_line).with("2\n")
      expect(subject).to receive(:parse_line).with("END\n") do
        subject.instance_eval { @file_ended = true }
      end
      subject.parse_file file_content
    end

    it 'Skips the rest of the file when stop_parsing is called' do
      expect(subject).to receive(:parse_line).with("1\n") { subject.stop_parsing }
      expect(subject).to_not receive(:parse_line).with("2\n")
      subject.parse_file file_content
    end

    it 'Fails when file is incomplete' do
      incomplete_file = StringIO.new "1\n"
      expect(subject).to receive(:parse_line).with("1\n")
      expect { subject.parse_file incomplete_file }
        .to raise_error RuntimeError, "File is incomplete. #{incomplete_file.inspect}"
    end
  end

  it '#parse_line' do
    expect { subject.parse_line '' }
      .to raise_error RuntimeError, 'parse_file MUST be implemented in the child class.'
  end
end
