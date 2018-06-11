require 'net/http'

module RailFeeds
  module NetworkRail
    # A wrapper class for ::Net::HTTP
    class HTTPClient
      HOST = 'datafeeds.networkrail.co.uk'.freeze

      # Initialize a new http client.
      # @ param [RailFeeds::NetworkRail::Credentials] credentials
      #   The credentials for connecting to the feed.
      # @ param [Logger] logger
      #   The logger for outputting evetns.
      def initialize(credentials: Credentials, logger: Logger.new(IO::NULL))
        @credentials = credentials
        @logger = logger
      end

      # Get path from network rail server.
      # Passes the (possible large) http response to an optionally passed block.
      # @ param [String] path
      #   The path to get.
      # @ return [String] the content of the page if no block is passed.
      def get(path, &block)
        uri = URI("https://#{HOST}/#{path}")
        uri.user = @credentials.username
        uri.password = @credentials.password

        if block_given?
          request = Net::HTTP::Get.new uri
          http = Net::HTTP.new uri.hostname, uri.port, use_ssl: true
          http.request request, &block
        else
          Net::HTTP.get(uri)
        end
      end
    end
  end
end
