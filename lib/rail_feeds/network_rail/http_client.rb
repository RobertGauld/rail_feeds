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

      # Fetch path from network rail server.
      # @param [String] path
      #   The path to fetch.
      # @yield [file] Once the block has run the temp file will be deleted.
      #   @yieldparam [Tempfile] file The content of the file.
      def fetch(path)
        file = download path
        yield file
      ensure
        file&.delete
      end

      # Fetch path from network rail server and unzip it.
      # @param [String] path
      #   The path to fetch.
      # @yield [reader] Once the block has run the temp file will be deleted.
      #   @yieldparam [Zlib::GzipReader] reader The unzippable content of the file.
      def fetch_unzipped(path)
        logger.debug "get_unzipped(#{path.inspect})"
        get(path) do |gz_file|
          logger.debug "gz_file = #{gz_file.inspect}"
          yield Zlib::GzipReader.open(gz_file.path)
        end
      end

      # Get path from network rail server.
      # @param [String] path
      #   The path to download.
      # @return [Tempfile] The downloaded file
      def download(path)
        logger.debug "download(#{path.inspect})"
        uri = URI("https://#{HOST}/#{path}")
        uri.open(http_basic_authentication: @credentials.to_a)
      end
    end
  end
end
