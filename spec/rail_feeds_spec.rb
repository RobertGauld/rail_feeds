# frozen_string_literal: true

describe RailFeeds do
  it 'Has a version' do
    expect(RailFeeds::Version).to_not be_nil
    expect(RailFeeds::Version::MAJOR).to_not be_nil
    expect(RailFeeds::Version::MINOR).to_not be_nil
    expect(RailFeeds::Version::PATCH).to_not be_nil
    expect(RailFeeds::Version.to_s).to_not be_empty
  end
end
