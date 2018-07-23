# frozen_string_literal: true

module RailFeeds
  module NationalRail
    # A Class to store username & password required to access national rail feeds
    # Can be used to set a global default but create new instances with
    # specific ones for a specific use.
    class Credentials < RailFeeds::Credentials
    end
  end
end
