# frozen_string_literal: true

require_relative 'network_rail/credentials'
require_relative 'network_rail/http_client'
require_relative 'network_rail/stomp_client'
require_relative 'network_rail/schedule'

module RailFeeds
  module NetworkRail # :nodoc:
  end
end

# Add alias for module
::NetRailFeeds = RailFeeds::NetworkRail
