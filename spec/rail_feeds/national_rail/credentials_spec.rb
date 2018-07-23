# frozen_string_literal: true

describe RailFeeds::NationalRail::Credentials do
  it 'Is a RailFeeds::Credentials' do
    expect(described_class).to be < RailFeeds::Credentials
  end

  it 'Has seperate values to RailFeeds::Credentials' do
    described_class.configure username: 'a', password: 'b'
    expect(described_class.username).to_not eq RailFeeds::Credentials.username
    expect(described_class.password).to_not eq RailFeeds::Credentials.password
  end
end
