# frozen_string_literal: true

module RailFeeds
  module NationalRail
    # A wrapper class for ::Net::HTTP
    class HTTPClient < RailFeeds::HTTPClient
      def initialize(credentials: nil, **args)
        credentials ||= RailFeeds::NationalRail::Credentials
        super
      end

      # Fetch path from server.
      # @param [String] path The path to fetch.
      # @yield contents
      #   @yieldparam [IO] file Either a Tempfile or StringIO.
      def fetch(path)
        super "https://datafeeds.nationalrail.co.uk/#{path}", 'X-Auth-Token' => auth_token
      end

      private

      # rubocop:disable Metrics/AbcSize
      def auth_token
        return @auth_token if !@auth_token.nil? && @auth_token_expires_at >= Time.now

        logger.info 'Getting an auth token for national rail.'
        response = Net::HTTP.post_form(
          URI('https://datafeeds.nationalrail.co.uk/authenticate'),
          credentials.to_h
        )
        response.value # Raise an exception if not successful
        data = JSON.parse(response.body)
        logger.debug "Got auth token data: #{data.inspect}"
        token = data.fetch('token')

        # Token expires in 1 hour. Using 55 minutes provides a safety margin.
        @auth_token_expires_at = Time.now + (55 * 60)
        logger.debug "Auth token expires at #{@auth_token_expires_at}."

        @auth_token = token
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
