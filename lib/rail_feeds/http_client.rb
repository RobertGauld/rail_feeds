# frozen_string_literal: true

module RailFeeds
  # A wrapper class for ::Net::HTTP
  class HTTPClient
    include Logging

    # Initialize a new http client.
    # @param [RailFeeds::Credentials] credentials
    #   The credentials for connecting to the feed.
    # @param [Logger] logger
    #   The logger for outputting evetns, if nil the global logger will be used.
    def initialize(credentials: nil, logger: nil)
      @credentials = credentials
      self.logger = logger unless logger.nil?
    end

    # Fetch path from server.
    # @param [String] url The URL to fetch.
    # @yield contents
    #   @yieldparam [IO] file Either a Tempfile or StringIO.
    def fetch(url, options = {})
      logger.debug "fetching #{url.inspect}"
      options[:http_basic_authentication] = @credentials.to_a
      yield URI(url).open(options)
    end

    # Fetch path from server and unzip it.
    # @param [String] url The URL to fetch. For child classes this is just the path.
    # @yield contents
    #   @yieldparam [Zlib::GzipReader] reader The unzippable content of the file.
    def fetch_unzipped(url)
      logger.debug "get_unzipped(#{url.inspect})"
      fetch(url) do |gz_file|
        reader = Zlib::GzipReader.new gz_file
        yield reader
      end
    end

    # Download path from server.
    # @param [String] url The URL to download. For child classes this is just the path.
    # @param [String] file The path to the file to save the contents in.
    def download(url, file)
      logger.debug "download(#{url.inspect}, #{file.inspect})"
      fetch(url) do |src|
        File.open(file, 'w') do |dst|
          IO.copy_stream src, dst
        end
      end
    end

    private

    attr_reader :credentials
  end
end
