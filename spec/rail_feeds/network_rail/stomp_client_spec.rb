describe RailFeeds::NetworkRail::StompClient do
  subject { described_class.new credentials: credentials, logger: logger }
  let :credentials do
    RailFeeds::NetworkRail::Credentials.new username: 'a', password: 'b'
  end
  let(:logger) { double Logger }

  it 'Sets correct options when delegating #connect' do
    stomp_client = double Stomp::Client
    options = {
      hosts: [{
        host: 'datafeeds.networkrail.co.uk',
        port: '61618',
        login: 'a',
        password: 'b'
      }],
      connect_headers: {
        'host' => 'datafeeds.networkrail.co.uk',
        'client-id' => 'a',
        'accept-version' => '1.1',
        'heart-beat' => '5000,10000'
      },
      logger: logger
    }
    expect(Stomp::Client).to receive(:new).with(options).and_return(stomp_client)
    subject.connect
  end

  describe 'Sets correct options when delegating #subscribe' do
    let(:stomp_client) { double Stomp::Client }

    before :each do
      allow(Socket).to receive(:gethostname).and_return('hostname')
      allow(stomp_client).to receive(:uuid).and_return('uuid')
      expect(Stomp::Client).to receive(:new).and_return(stomp_client)
    end

    describe 'When connected' do
      before :each do
        subject.connect
        allow(stomp_client).to receive(:closed?).and_return(false)
      end

      it 'No headers passes' do
        headers = {
          'activemq.subscriptionName' => 'hostname+topic',
          'id' => 'uuid',
          'ack' => 'client'
        }
        expect(stomp_client).to receive(:subscribe).with('/topic/topic', headers)
        subject.subscribe('topic') { |m| puts m }
      end

      it 'Appends to added headers' do
        headers = {
          'activemq.subscriptionName' => 'hostname+topic',
          'id' => 'uuid',
          'ack' => 'client',
          'test' => 'TEST'
        }
        expect(stomp_client).to receive(:subscribe).with('/topic/topic', headers)
        subject.subscribe('topic', 'test' => 'TEST') { |m| puts m }
      end

      it "Doesn't overwrite passed headers" do
        headers = {
          'activemq.subscriptionName' => 'a',
          'id' => 'b',
          'ack' => 'c'
        }
        expect(stomp_client).to receive(:subscribe).with('/topic/topic', headers)
        subject.subscribe('topic', headers) { |m| puts m }
      end
    end

    it 'When not connected' do
      headers = {
        'activemq.subscriptionName' => 'hostname+topic',
        'id' => 'uuid',
        'ack' => 'client'
      }
      expect(stomp_client).to receive(:subscribe).with('/topic/topic', headers)
      expect { subject.subscribe('topic') { |m| puts m } }.to_not raise_error
    end
  end

  describe '#disconnect delegates #close' do
    it 'When connected' do
      stomp_client = double Stomp::Client
      expect(Stomp::Client).to receive(:new).and_return(stomp_client)
      subject.connect
      expect(stomp_client).to receive(:close)
      subject.disconnect
    end

    it 'When not connected' do
      expect { subject.disconnect }.to_not raise_error
    end
  end

  describe 'Delegates methods to Stomp::Client' do
    delegates = [
      :ack, :acknowledge, :nack, :unreceive, :create_error_handler,
      :open?, :closed?, :join, :running?, :begin, :abort, :commit, :unsubscribe,
      :uuid, :poll, :hbsend_interval, :hbrecv_interval, :hbsend_count, :hbrecv_count
    ]
    delegates.each do |method|
      it method do
        stomp_client = double Stomp::Client
        expect(Stomp::Client).to receive(:new).and_return(stomp_client)
        expect(stomp_client).to receive(method)
        subject.connect
        subject.send method
      end
    end
  end
end
