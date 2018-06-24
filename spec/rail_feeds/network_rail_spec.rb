# frozen_string_literal: true

describe RailFeeds::NetworkRail do
  it 'Has NetRailFeeds as an alias' do
    expect(::NetRailFeeds).to be RailFeeds::NetworkRail
  end
end
