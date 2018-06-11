# frozen_string_literal: true

require 'net/http'

module RailFeeds
  module NetworkRail
    module Schedule
      # A class for fetching the schedule data files.
      class Fetcher
        # Initialize a new schedule
        # @param [RailFeeds::NetworkRail::Credentials] credentials
        #   The credentials for connecting to the feed.
        # @param [Logger] logger
        #   The logger for outputting events.
        def initialize(credentials: Credentials, logger: Logger.new(IO::NULL))
          @credentials = credentials
          @logger = logger
        end

        # Fetch a schedule.
        # @param [:full, :update] type
        #   Whether to get the full schedule (published on Friday) or the daily update
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for:
        #   * nil - the whole schedule
        #   * "FREIGHT" - the freight schedule
        #   * Anything else - the TOC code
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        #   :cif is only available for the full schedule.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch(type, toc: nil, day: nil, format: :json)
          if toc.nil? # Getting all TOCs
            unless %i[cif json].include?(format)
              fail ArgumentError, 'format must be either :json or :cif'
            end
          else # Getting specific TOC / freight
            fail ArgumentError, 'format must be :json' unless format.eql?(:json)
          end

          path = path_for_schedule(type, toc, day)
          path += '.CIF.gz' if format.eql?(:cif)

          client = HTTPClient.new(credentials: @credentials, logger: @logger)
          client.get_unzipped(path)
        end

        # Fetch the full schedule.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_all_full(format = :json)
          fetch(:full, format: format)
        end

        # Fetch the daily update to the full schedule.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_all_update(day = nil, format = :json)
          fetch(:update, format: format, day: day)
        end

        # Fetch the freight schedule.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_freight_full
          fetch(:full, toc: 'FREIGHT')
        end

        # Fetch the daily update to the freight schedule.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_freight_update(day = nil)
          fetch(:update, toc: 'FREIGHT', day: day)
        end

        # Fetch the schedule for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_toc_full(toc)
          fetch(:full, toc: toc)
        end

        # Fetch the daily update for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @param [String, #to_s] day
        #   The day to get the update schedule for ("mon", "tue", "wed", ...).
        #   Defaults to the current day.
        # @return [Zlib::GzipReader] the unzippedable content of the file.
        def fetch_toc_update(toc, day = nil)
          fetch(:update, toc: toc, day: day)
        end

        private

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def path_for_schedule(type, toc = nil, day = nil)
          @logger.debug "path_for_schedule #{type.inspect}, " \
                        "#{toc.inspect}, #{day.inspect}"
          # CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full
          # CifFileAuthenticate?type=CIF_ALL_FULL_DAILY&day=toc-full.CIF.gz
          # CifFileAuthenticate?type=CIF_XX_TOC_FULL_DAILY&day=toc-full
          # CifFileAuthenticate?type=CIF_FREIGHT_FULL_DAILY&day=toc-full

          # CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon
          # CifFileAuthenticate?type=CIF_ALL_UPDATE_DAILY&day=toc-update-mon.CIF.gz
          # CifFileAuthenticate?type=CIF_XX_TOC_UPDATE_DAILY&day=toc-update-thu
          # CifFileAuthenticate?type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-wed

          toc = toc.to_s.upcase
          if toc.eql?('')
            # We want everything
            toc = 'ALL'
          elsif toc.eql?('FREIGHT')
            # Do nothing it's already as we want it
          else
            toc = "#{toc}_TOC"
          end

          if type.eql?(:update)
            day ||= Time.now.strftime('%a')
            day = day.to_s[0..2].downcase
            unless %w[mon tue wed thu fri sat sun].include?(day)
              fail ArgumentError, 'day is invalid'
            end
            day = "toc-update-#{day}"
          end

          day = 'toc-full' if type.eql?(:full)

          type = type.to_s.upcase

          "ntrod/CifFileAuthenticate?type=CIF_#{toc}_#{type}_DAILY&day=#{day}"
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
