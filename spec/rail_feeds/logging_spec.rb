# frozen_string_literal: true

class DummyClassForLoggerTests
  include RailFeeds::Logging
end

describe RailFeeds::Logging do
  let(:global_logger) { double Logger }

  it 'Default system logger' do
    described_class.logger = nil
    formatter = double Proc
    expect(described_class).to receive(:formatter).and_return(formatter)
    expect(Logger).to receive(:new).with(
      STDOUT,
      formatter: formatter,
      level: Logger::DEBUG
    ).and_return(global_logger)
    expect(described_class.logger).to be global_logger
  end

  describe 'Default system formatter' do
    subject { described_class.formatter }
    it 'With all items passed in' do
      expect(subject.call('s', 'd', 'p', 'm')).to eq "d p s: m\n"
    end

    it 'Without progname' do
      expect(subject.call('S', 'D', nil, 'M')).to eq "D S: M\n"
    end
  end

  context 'included in a class' do
    let(:klass) { DummyClassForLoggerTests }
    let(:instance) { klass.new }
    before(:each) do
      allow(described_class).to receive(:logger).and_return(global_logger)
    end
    let(:class_logger) { double Logger }
    let(:instance_logger) { double Logger }

    describe 'Defaults to using global logger' do
      it '::logger' do
        expect(klass.logger).to be global_logger
      end

      it '#logger' do
        expect(instance.logger).to be global_logger
      end
    end

    describe 'Setting custom logger for class' do
      before(:each) { klass.logger = class_logger }

      it 'Global logger is unaffected' do
        expect(described_class.logger).to be global_logger
      end
      it 'Instance defaults to using class logger' do
        expect(instance.logger).to be class_logger
      end
      it 'Sets class logger' do
        expect(klass.logger).to be class_logger
      end
    end

    describe 'Setting custom logger for instance' do
      before(:each) { klass.logger = class_logger }
      before(:each) { instance.logger = instance_logger }

      it 'Global logger is unaffected' do
        expect(described_class.logger).to be global_logger
      end
      it 'Class logger is unaffected' do
        expect(klass.logger).to be class_logger
      end
      it 'Sets instance logger' do
        expect(instance.logger).to be instance_logger
      end
    end
  end
end
