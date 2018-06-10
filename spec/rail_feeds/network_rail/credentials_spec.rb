describe RailFeeds::NetworkRail::Credentials do
  it 'Has seperate values to RailFeeds::Credentials' do
    described_class.configure username: 'a', password: 'b'
    expect(described_class.username).to_not eq RailFeeds::Credentials.username
  end
end
