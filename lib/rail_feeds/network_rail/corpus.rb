# frozen_string_literal: true

require 'json'

module RailFeeds
  module NetworkRail
    # A module for getting information out of the CORPUS data.
    module CORPUS
      Data = Struct.new(
        :tiploc, :stanox, :crs, :uic, :nlc, :nlc_description, :nlc_short_description
      )

      # Download the current CORPUS data.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      # @param [String] file
      #   The path to the file to save the .json.gz download in.
      def self.download(file, credentials: Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.download 'ntrod/SupportingFileAuthenticate?type=CORPUS', file
      end

      # Fetch the current CORPUS data.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      # @return [IO]
      def self.fetch(credentials: Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.fetch 'ntrod/SupportingFileAuthenticate?type=CORPUS'
      end

      # Load CORPUS data from either a .json or .json.gz file.
      # @param [String] file The path of the file to open.
      # @return [Array<RailFeeds::NetworkRail::CORPUS::Data>]
      def self.load_file(file)
        Zlib::GzipReader.open(file) do |gz|
          parse_json gz.read
        end
      rescue Zlib::GzipFile::Error
        parse_json File.read(file)
      end

      # Load CORPUS data from the internet.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      #  The credentials to authenticate with.
      # @return [Array<RailFeeds::NetworkRail::CORPUS::Data>]
      def self.fetch_data(credentials: Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.fetch_unzipped('ntrod/SupportingFileAuthenticate?type=CORPUS') do |file|
          break parse_json file.read
        end
      end

      # rubocop:disable Metrics/AbcSize
      def self.parse_json(json)
        data = JSON.parse json
        data['TIPLOCDATA'].map do |item|
          Data.new(
            nilify(item['TIPLOC']&.strip),
            nilify(item['STANOX']&.strip)&.to_i,
            nilify(item['3ALPHA']&.strip),
            nilify(item['UIC']&.strip)&.to_i,
            nilify(item['NLC']&.strip),
            nilify(item['NLCDESC']&.strip),
            nilify(item['NLCDESC16']&.strip)
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
      private_class_method :parse_json

      def self.nilify(item)
        return nil if item.nil? || item.empty?
        item
      end
      private_class_method :nilify
    end
  end
end
