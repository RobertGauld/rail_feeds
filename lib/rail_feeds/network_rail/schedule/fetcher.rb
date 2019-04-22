# frozen_string_literal: true

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

        # Download the full schedule.
        # @param [:json, :cif] format
        #   The format to download the schedule in.
        # @param [String] file
        #   The path to the file to save the .json.gz / .cif.gz download in.
        def download_all_full(format, file)
          download 'ALL', 'full', format, file
        end

        # Download the daily update to the full schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @param [String] file
        #   The path to the file to save the .json.gz / .cif.gz download in.
        def download_all_update(day, format, file)
          download 'ALL', day, format, file
        end

        # Fetch the freight schedule.
        # @param [String] file
        #   The path to the file to save the .json.gz download in.
        def download_freight_full(file)
          download 'FREIGHT', 'full', :json, file
        end

        # Fetch the daily update to the freight schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @param [String] file
        #   The path to the file to save the .json.gz download in.
        def download_freight_update(day, file)
          download 'FREIGHT', day, :json, file
        end

        # Fetch the schedule for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @param [String] file
        #   The path to the file to save the .json.gz download in.
        def download_toc_full(toc, file)
          download toc, 'full', :json, file
        end

        # Fetch the daily update for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @param [String] file
        #   The path to the file to save the .json.gz download in.
        def download_toc_update(toc, day, file)
          download toc, day, :json, file
        end

        # Fetch the full schedule.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all_full(format, &block)
          fetch 'ALL', 'full', format, &block
        end

        # Fetch the daily update to the full schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all_update(day, format, &block)
          fetch 'ALL', day, format, &block
        end

        # Fetch the freight schedule.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_freight_full(&block)
          fetch 'FREIGHT', 'full', :json, &block
        end

        # Fetch the daily update to the freight schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [TempFile] file The unzippable content of the file.
        def fetch_freight_update(day, &block)
          fetch 'FREIGHT', day, :json, &block
        end

        # Fetch the schedule for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_toc_full(toc, &block)
          fetch toc, 'full', :json, &block
        end

        # Fetch the daily update for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_toc_update(toc, day, &block)
          fetch toc, day, :json, &block
        end

        private

        # Fetch a schedule.
        def fetch(toc, day, format, &block)
          path = path_for toc, day, format
          client = HTTPClient.new(credentials: @credentials, logger: logger)
          client.fetch_unzipped(path, &block)
        end

        # Download a schedule.
        def download(toc, day, format, file)
          path = path_for toc, day, format
          client = HTTPClient.new(credentials: @credentials, logger: logger)
          client.download(path, file)
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        # Get the path for a schedule
        def path_for(toc, day, format)
          toc = "#{toc}_TOC" unless %w[ALL FREIGHT].include?(toc)

          if format.eql?(:cif)
            unless toc.eql?('ALL')
              fail ArgumentError, 'CIF format is only available for the all schedule'
            end
          else
            unless format.eql?(:json)
              fail ArgumentError, 'format must be either :json or :cif'
            end
          end

          if day.eql?('full')
            day = 'toc-full'
            type = "CIF_#{toc}_FULL_DAILY"
          else
            unless %w[mon tue wed thu fri sat sun].include?(day)
              fail ArgumentError, 'day is invalid'
            end
            day = "toc-update-#{day}"
            type = "CIF_#{toc}_UPDATE_DAILY"
          end

          path = "ntrod/CifFileAuthenticate?type=#{type}&day=#{day}"
          format.eql?(:cif) ? "#{path}.CIF.gz" : path
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity
      end
    end
  end
end
