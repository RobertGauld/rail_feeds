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
          fetch 'type=CIF_ALL_FULL_DAILY&day=toc-full', format, &block
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

          fetch "type=CIF_ALL_UPDATE_DAILY&day=toc-update-#{day}", format, &block
        end

        # Fetch the full schedule and all following updates.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @yield [file] Once the block has run the temp file will be deleted.
        # Yielded for the full extract then for each update.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all(format = :json, &block)
          header = nil

          logger.info 'Fetching full extract.'
          fetch_all_full(format) do |file|
            header = Header.send "from_#{format}", file.readline
            file.rewind
            yield file
          end

          first_update = header.start_date + 1
          fetch_all_updates first_update, format, &block
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # Fetch the full schedule updates since a given date.
        # @param [Date] first_update
        #   The date of the first update to fetch.
        # @param [:json, :cif] format
        #   The format to fetch the schedule in.
        # @yield [file] Once the block has run the temp file will be deleted.
        # Yielded for each update.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_all_updates(first_update, format = :json)
          if first_update > Time.now.utc.to_date
            fail ArgumentError, 'Can\'t get updates from the future.'
          end
          if first_update < Date.today - 6
            fail ArgumentError, 'Updates are only available from the last 7 days.'
          end

          last_update = guess_last_update format
          logger.info "Getting updates between #{first_update} and #{last_update}."
          (first_update..last_update).each do |date|
            logger.debug "Getting update extract for #{date}."
            day = date.strftime('%a').downcase
            fetch_all_update(day, format) do |file|
              header = Header.send "from_#{format}", file.readline
              next unless header.extracted_at.to_date == date
              # We guessed wring - the update is not available yet
              file.rewind
              yield file
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        # Fetch the freight schedule.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_freight_full(&block)
          fetch 'type=CIF_FREIGHT_FULL_DAILY&day=toc-full', :json, &block
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

          fetch "type=CIF_FREIGHT_UPDATE_DAILY&day=toc-update-#{day}", :json, &block
        end

        # Fetch the schedule for a TOC.
        # @param [String, #to_s, nil] toc
        #   The TOC to get the schedule for.
        # @yield [file] Once the block has run the temp file will be deleted.
        #   @yieldparam [Zlib::GzipReader] file The unzippable content of the file.
        def fetch_toc_full(toc, &block)
          fetch "type=CIF_#{toc}_TOC_FULL_DAILY&day=toc-full", :json, &block
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

          fetch "type=CIF_#{toc}_TOC_UPDATE_DAILY&day=toc-update-#{day}", :json, &block
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
        def fetch(query_string, format, &block)
          path = 'ntrod/CifFileAuthenticate?' + query_string
          path += '.CIF.gz' if format.eql?(:cif)

          client = HTTPClient.new(credentials: @credentials, logger: logger)
          client.get_unzipped(path, &block)
        end

        def guess_last_update(format)
          # From https://wiki.openraildata.com/index.php/SCHEDULE
          # CIF format available from 0100 the following day
          # JSON format available from 0600 the following day
          case format
          when :cif
            available_from = '0100'
          when :json
            available_from = '0600'
          else
            fail ArgumentError, "#{format.inspect} is an invalid format."
          end

          if Time.now.utc.strftime('%H%M') > available_from
            # We can get yesterdays
            Time.now.utc.to_date - 1
          else
            # We can only get the day before yesterdays
            Time.now.utc.to_date - 2
          end
        end
      end
    end
  end
end
