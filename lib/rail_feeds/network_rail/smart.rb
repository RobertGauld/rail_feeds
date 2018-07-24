# frozen_string_literal: true

require 'json'
require 'set'

module RailFeeds
  module NetworkRail
    # rubocop:disable Metrics/ModuleLength
    # A module for getting information out of the SMART data.
    module SMART
      Step = Struct.new(
        :td_area, :from_berth, :to_berth, :step_type, :event_direction, :from_line,
        :to_line, :trust_offset, :platform, :event_type, :route, :stanox,
        :stanox_name, :comment
      ) do
        def from_direction
          return :up if event_direction.eql?(:down)
          return :down if event_direction.eql?(:up)
          nil
        end

        def to_direction
          event_direction
        end
      end

      Berth = Struct.new(
        :id, :up_steps, :down_steps, :up_berths, :down_berths
      )

      # Download the current SMART data.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      # @param [String] file
      #   The path to the file to save the .json.gz download in.
      def self.download(file, credentials = Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.download 'ntrod/SupportingFileAuthenticate?type=SMART', file
      end

      # Fetch the current SMART data.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      # @return [IO]
      def self.fetch(credentials = Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.fetch 'ntrod/SupportingFileAuthenticate?type=SMART'
      end

      # Load SMART data from either a .json or .json.gz file.
      # @param [String] file The path of the file to open.
      # @return [Array<RailFeeds::NetworkRail::SMART::Step>]
      def self.load_file(file)
        Zlib::GzipReader.open(file) do |gz|
          parse_json gz.read
        end
      rescue Zlib::GzipFile::Error
        parse_json File.read(file)
      end

      # Load SMART data from the internet.
      # @param [RailFeeds::NetworkRail::Credentials] credentials
      #  The credentials to authenticate with.
      # @return [Array<RailFeeds::NetworkRail::SMART::Step>]
      def self.fetch_data(credentials = Credentials)
        client = HTTPClient.new(credentials: credentials)
        client.fetch_unzipped('ntrod/SupportingFileAuthenticate?type=SMART') do |file|
          break parse_json file.read
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # Generate an berth data from step data.
      # You'll get an array of berths which list the steps into and out of them,
      # which in turn have references to other (via the to_berth attribute) to
      # other berths.
      # @param [Array<RailFeeds::NetworkRail::SMART::Step] steps
      #   The steps to build the berth information from.
      # @return [Hash{String=>Hash{String=>RailFeeds::NetworkRail::SMART::Step}}
      #  Nested hashes which take a String for the td_area, then a String for
      # the berth.id (from either step.from_berth or step.to_berth) to get a
      # specific berth.
      def self.build_berths(steps)
        berths = Hash.new do |hash, key|
          hash[key] = Hash.new do |hash2, key2|
            hash2[key2] = Berth.new nil, Set.new, Set.new, Set.new, Set.new
          end
        end

        steps.each do |step|
          next if step.event_direction.nil?

          # from_berth -> step -> to_berth   --->  up
          from_berth = berths.dig(step.td_area, step.from_berth)
          to_berth = berths.dig(step.td_area, step.to_berth)

          from_berth.id ||= step.from_berth
          to_berth.id ||= step.to_berth

          from_berth.send("#{step.to_direction}_steps").add step
          to_berth.send("#{step.from_direction}_steps").add step
          from_berth.send("#{step.to_direction}_berths").add step.to_berth
        end

        # Convert sets to arrays
        berths.each do |_area, hash|
          hash.each do |_id, value|
            value.up_steps = value.up_steps.to_a
            value.down_steps = value.down_steps.to_a
            value.up_berths = value.up_berths.to_a
            value.down_berths = value.down_berths.to_a
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # private methods below

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.parse_json(json)
        data = JSON.parse json
        data['BERTHDATA'].map do |item|
          Step.new(
            nilify(item['TD']&.strip),
            nilify(item['FROMBERTH']&.strip),
            nilify(item['TOBERTH']&.strip),
            step_type(item['STEPTYPE']),
            event_direction(item['EVENT']),
            nilify(item['FROMLINE']&.strip),
            nilify(item['TOLINE']&.strip),
            (item['BERTHOFFSET']&.to_i || 0),
            nilify(item['PLATFORM']&.strip),
            event_type(item['EVENT']),
            nilify(item['ROUTE']&.strip),
            nilify(item['STANOX']&.strip)&.to_i,
            nilify(item['STANME']&.strip),
            nilify(item['COMMENT']&.strip)
          )
          # berths[step.from_berth].up_steps.push ....
          # berths[step.to_berth].down_steps.push ....
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      private_class_method :parse_json

      def self.nilify(value)
        return nil if value.nil? || value.empty?
        value
      end
      private_class_method :nilify

      def self.event_type(value)
        return :arrive if value.eql?('A') || value.eql?('C')
        return :depart if value.eql?('B') || value.eql?('D')
        nil
      end
      private_class_method :event_type

      def self.event_direction(value)
        return :up if value.eql?('A') || value.eql?('B')
        return :down if value.eql?('C') || value.eql?('D')
        nil
      end
      private_class_method :event_direction

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def self.step_type(value)
        return :between if value.eql?('B')
        return :from if value.eql?('F')
        return :to if value.eql?('T')
        return :intermediate_first if value.eql?('D')
        return :clearout if value.eql?('C')
        return :interpose if value.eql?('I')
        return :intermediate if value.eql?('E')
        nil
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
      private_class_method :step_type
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
