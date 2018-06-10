require_relative 'network_rail/credentials'
require_relative 'network_rail/stomp_client'

module RailFeeds
  module NetworkRail # :nodoc:
  end
end

# Add alias for module
::NetRailFeeds = RailFeeds::NetworkRail
