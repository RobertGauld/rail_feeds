# frozen_string_literal: true

describe RailFeeds::NationalRail do
  it 'Has NatRailFeeds as an alias' do
    expect(::NatRailFeeds).to be RailFeeds::NationalRail
  end
end
