# frozen_string_literal: true

require 'open-uri'

module RailFeeds
  module NetworkRail
    # A wrapper class for ::Net::HTTP
    class HTTPClient
      include Logging

      HOST = 'datafeeds.networkrail.co.uk'

      # Initialize a new http client.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      #   The credentials for connecting to the feed.
      # @param [Logger] logger
      #   The logger for outputting evetns, if nil the global logger will be used.
      def initialize(credentials: Credentials, logger: nil)
        @credentials = credentials
        self.logger = logger unless logger.nil?
      end

      # Get path from network rail server.
      # @param [String] path
      #   The path to get.
      # @yield [file] Once the block has run the temp file will be deleted.
      #   @yieldparam [Tempfile] file The content of the file.
      def get(path)
        logger.debug "get(#{path.inspect})"
        uri = URI("https://#{HOST}/#{path}")
        file = uri.open(http_basic_authentication: @credentials.to_a)
        yield file
        file.delete
      end

      # Get path from network rail server and unzip it.
      # @param [String] path
      #   The path to get.
      # @yield [reader] Once the block has run the temp file will be deleted.
      #   @yieldparam [Zlib::GzipReader] reader The unzippable content of the file.
      def get_unzipped(path)
        logger.debug "get_unzipped(#{path.inspect})"
        gz_file = get(path)
        logger.debug "gz_file = #{gz_file.inspect}"
        yield Zlib::GzipReader.open(gz_file.path)
      end
    end
  end
end
