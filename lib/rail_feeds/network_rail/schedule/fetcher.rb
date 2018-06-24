# frozen_string_literal: true

require 'net/http'

module RailFeeds
  module NetworkRail
    module Schedule
      # A class for fetching the schedule data files.
      class Fetcher
        include Logging

        # Initialize a new schedule
        # @param [RailFeeds::NetworkRail::Credentials] credentials
        #   The credentials for connecting to the feed.
        # @param [Logger, nil] logger
        #   The logger for outputting events, if nil the global logger will be used.
        def initialize(credentials: Credentials, logger: nil)
          @credentials = credentials
          self.logger = logger unless logger.nil?
        end

        # Fetch the full schedule.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all_full(format = :json, &block)
          unless %i[cif json].include?(format)
            fail ArgumentError, 'format must be either :json or :cif'
          end
          fetch 'type=CIF_ALL_FULL_DAILY&day=toc-full', format: format, &block
        end

        # Fetch the daily update to the full schedule.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all_update(day = nil, format = :json, &block)
          unless %i[cif json].include?(format)
            fail ArgumentError, 'format must be either :json or :cif'
          end

          day = day.to_s[0..2].downcase
          unless %w[mon tue wed thu fri sat sun].include?(day)
            fail ArgumentError, 'day is invalid'
          end

          fetch "type=CIF_ALL_UPDATE_DAILY&day=toc-update-#{day}", format: format, &block
        end

        # Fetch the freight schedule.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_freight_full(&block)
          fetch 'type=CIF_FREIGHT_FULL_DAILY&day=toc-full', &block
        end

        # Fetch the daily update to the freight schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [TempFile] file The unzippable content of the file.
        def fetch_freight_update(day = nil, &block)
          day = day.to_s[0..2].downcase
          unless %w[mon tue wed thu fri sat sun].include?(day)
            fail ArgumentError, 'day is invalid'
          end

          fetch "type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-#{day}", &block
        end

        # Fetch the schedule for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_toc_full(toc, &block)
          fetch "type=CIF_#{toc}_TOC_FULL_DAILY&day=toc-full", &block
        end

        # Fetch the daily update for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_toc_update(toc, day = nil, &block)
          day = day.to_s[0..2].downcase
          unless %w[mon tue wed thu fri sat sun].include?(day)
            fail ArgumentError, 'day is invalid'
          end

          fetch "type=CIF_#{toc}_TOC_UPDATE_DAILY&day=toc-update-#{day}", &block
        end

        private

        # Fetch a schedule.
        # @param [Hash] query_string
        #   The query_string to use in making the request.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        #   :cif is only available for the full schedule.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch(query_string, format: :json, &block)
          path = 'ntrod/CifFileAuthenticate?' + query_string
          path += '.CIF.gz' if format.eql?(:cif)

          client = HTTPClient.new(credentials: @credentials, logger: logger)
          client.get_unzipped(path, &block)
        end
      end
    end
  end
end
