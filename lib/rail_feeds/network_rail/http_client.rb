# frozen_string_literal: true

require 'open-uri'

module RailFeeds
  module NetworkRail
    # A wrapper class for ::Net::HTTP
    class HTTPClient < RailFeeds::HTTPClient
      def initialize(credentials = nil, **args)
        credentials ||= RailFeeds::NetworkRail::Credentials
        super
      end

      # Fetch path from server.
      # @param [String] path The path to fetch.
      # @yield contents
      #   @yieldparam [IO] file Either a Tempfile or StringIO.
      def fetch(path)
        super "https://datafeeds.networkrail.co.uk/#{path}"
      end
    end
  end
end
