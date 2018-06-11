# frozen_string_literal: true

require 'cgi'
require 'open-uri'

module RailFeeds
  module NetworkRail
    # A wrapper class for ::Net::HTTP
    class HTTPClient
      HOST = 'datafeeds.networkrail.co.uk'

      # Initialize a new http client.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      #   The credentials for connecting to the feed.
      # @param [Logger] logger
      #   The logger for outputting evetns.
      def initialize(credentials: Credentials, logger: Logger.new(IO::NULL))
        @credentials = credentials
        @logger = logger
      end

      # Get path from network rail server.
      # @param [String] path
      #   The path to get.
      # @return [TempFile] the content of the file.
      def get(path)
        @logger.debug "get(#{path.inspect})"
        uri = URI("https://#{HOST}/#{path}")
        uri.open(http_basic_authentication: @credentials.to_a)
      end

      # Get path from network rail server and unzip it.
      # @param [String] path
      #   The path to get.
      # @return [Zlib::GzipReader] the unzippedable content of the file.
      def get_unzipped(path)
        @logger.debug "get_unzipped(#{path.inspect})"
        gz_file = get(path)
        @logger.debug "gz_file = #{gz_file.inspect}"
        Zlib::GzipReader.open(gz_file.path)
      end
    end
  end
end
