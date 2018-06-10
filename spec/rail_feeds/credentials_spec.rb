describe RailFeeds::Credentials do
  context 'Using system wide credentials' do
    before :each do
      described_class.configure(
        username: 'user@example.com',
        password: 'P@55word'
      )
    end

    it 'Sets class attributes' do
      expect(described_class.username).to eq 'user@example.com'
      expect(described_class.password).to eq 'P@55word'
    end

    it 'A new instance defaults to class attributes' do
      expect(subject.username).to eq 'user@example.com'
      expect(subject.password).to eq 'P@55word'
    end
  end


  context 'Using specific credentials' do
    subject do
      described_class.new(
        username: 'user2@example.com',
        password: 'P@55word2'
      )
    end

    before :each do
      described_class.configure username: nil, password: nil
    end

    it 'Sets instance attributes' do
      expect(subject.username).to eq 'user2@example.com'
      expect(subject.password).to eq 'P@55word2'
    end

    it 'Leaves class attributes alone' do
      expect(described_class.username).to eq ''
      expect(described_class.password).to eq ''
    end
  end
end
