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
      # @param [String] path The path to fetch.
      # @yield [file] Once the block has run the temp file will be deleted.
      #   @yieldparam [Tempfile] file The content of the file.
      def fetch(path)
        logger.debug "fetch(#{path.inspect})"
        uri = URI("https://#{HOST}/#{path}")
        opened_uri = uri.open(http_basic_authentication: @credentials.to_a)

        if opened_uri.is_a?(StringIO)
          data = opened_uri
          opened_uri = Tempfile.open 'rail_feeds-network_rail-http_client'
          opened_uri.write data
          opened_uri.rewind
        end

        yield opened_uri
      end

      # Fetch path from network rail server and unzip it.
      # @param [String] path The path to fetch.
      # @yield [reader] Once the block has run the temp file will be deleted.
      #   @yieldparam [Zlib::GzipReader] reader The unzippable content of the file.
      def fetch_unzipped(path)
        logger.debug "get_unzipped(#{path.inspect})"
        fetch(path) do |gz_file|
          reader = Zlib::GzipReader.new gz_file
          yield reader
        end
      end

      # Download path from netwrok rail server.
      # @param [String] path The path to download.
      # @param [String] file The path to the file to save the contents in.
      def download(path, file)
        logger.debug "download(#{path.inspect}, #{file.inspect})"
        fetch(path) do |src|
          File.open(file, 'w') do |dst|
            IO.copy_stream src, dst
          end
        end
      end
    end
  end
end
