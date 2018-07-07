# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      # rubocop:disable Metrics/ClassLength
      # A class for holding schedule data read from schedule file(s).
      class Data
        include Logging

        # @!attribute [r] last_header The last header added.
        # @return [RailFeeds::NetworkRail::Schedule::Header::CIF]
        # @!attribute [r] associations
        # @return [Hash<RailFeeds::NetworkRail::Schedule::Association>]
        # @!attribute [r] tiplocs
        # @return [Hash<RailFeeds::NetworkRail::Schedule::Tiploc>]
        # @!attribute [r] trains
        # @return [Hash{String=>RailFeeds::NetworkRail::Schedule::TrainSchedule}]
        # Schedules grouped by the train's UID

        attr_accessor :last_header, :associations, :tiplocs, :trains

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # Initialize a new data.
        # @param [Logger, nil] logger
        #   The logger for outputting events, if nil the global logger is used.
        def initialize(logger: nil)
          self.logger = logger unless logger.nil?
          @parser = Parser::CIF.new(
            logger: logger,
            on_header: proc { |*args| do_header(*args) },
            on_trailer: proc { |*args| do_trailer(*args) },
            on_tiploc_create: proc { |*args| do_tiploc_create(*args) },
            on_tiploc_update: proc { |*args| do_tiploc_update(*args) },
            on_tiploc_delete: proc { |*args| do_tiploc_delete(*args) },
            on_association_create: proc { |*args| do_association_create(*args) },
            on_association_update: proc { |*args| do_association_update(*args) },
            on_association_delete: proc { |*args| do_association_delete(*args) },
            on_train_schedule_create: proc { |*args| do_train_schedule_create(*args) },
            on_train_schedule_update: proc { |*args| do_train_schedule_update(*args) },
            on_train_schedule_delete: proc { |*args| do_train_schedule_delete(*args) }
          )
          reset_data
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        # Load data files into the parser, of types:
        #  * Full CIF file - the data will be replaced
        #  * Update CIF file - the data will be changed
        # @param [IO] file
        #   The file to load data from.
        def load_cif_file(file)
          @parser.parse_cif_file file

          logger.info "Currently have #{associations.count} associations, " \
                      "#{tiplocs.count} tiplocs, #{trains.count} trains."
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # Get the contained data in CIF format
        # Expects a block to receive each line
        def generate_cif
          fail 'No loaded data' if last_header.nil?

          header = Header::CIF.new(
            extracted_at: last_header.extracted_at,
            update_indicator: 'F',
            start_date: last_header.start_date,
            end_date: last_header.end_date
          )

          yield "/!! Start of file\n"
          yield "/!! Generated: #{header.extracted_at.utc&.strftime('%d/%m/%Y %H:%M')}\n"
          yield header.to_cif
          tiplocs.values.sort.each { |tiploc| yield tiploc.to_cif }
          associations.values.sort.each { |association| yield association.to_cif }
          trains.values.flatten.sort.each do |train_schedule|
            train_schedule.to_cif.each_line { |line| yield line }
          end
          yield "ZZ#{' ' * 78}\n"
          yield "/!! End of file\n"
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        # Fetch data over the web.
        # Gets the feed of all trains.
        # @param [RailFeeds::NetworkRail::Credentials] credentials
        #   The credentials for connecting to the feed.
        # @return [RailFeeds::NetworkRail::Schedule::Header::CIF]
        #   The header of the last file added.
        def fetch_data(credentials: Credentials)
          fetcher = Fetcher.new credentials: credentials

          method = if last_header.nil? ||
                      last_header.extracted_at.to_date < Date.today - 6
                     # Need to get a full andthen updates
                     :fetch_all
                   else
                     # Can only get updates
                     :fetch_all_updates
                   end

          fetcher.send(method, :cif) do |file|
            load_cif_file file
          end
        end

        private

        def reset_data
          @last_header = nil
          @associations = {}
          @tiplocs = {}
          @trains = {}
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/PerceivedComplexity
        def ensure_correct_update_order(header)
          if last_header.nil?
            # No data whatsoever - this must be a full extract
            unless header.full?
              fail ArgumentError,
                   'Update can\'t be loaded before loading a full extract.'
            end

          elsif last_header.update? && header.update?
            # Check against last update
            if header.extracted_at < last_header.extracted_at
              fail ArgumentError,
                   'Update is too old, it is before the last applied update.'
            end
            if header.previous_file_reference != last_header.current_file_reference
              fail ArgumentError,
                   'Missing update(s). Last applied update is ' \
                   "#{last_header.current_file_reference.inspect}, " \
                   "this update requires #{header.previous_file_reference.inspect} " \
                   'to be the previous applied update.'
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/PerceivedComplexity

        # Header record
        def do_header(_parser, header)
          ensure_correct_update_order header
          reset_data if header.full?
          @last_header = header
        end

        # TIPLOC Insert record
        def do_tiploc_create(_parser, tiploc)
          tiplocs[tiploc.hash] = tiploc
        end

        # TIPLOC Amend record
        def do_tiploc_update(_parser, tiploc_id, tiploc)
          tiplocs[tiploc_id] = tiploc
        end

        # TIPLOC Delete record
        def do_tiploc_delete(_parser, tiploc)
          tiplocs.delete tiploc.hash
        end

        # Association New record
        def do_association_create(_parser, association)
          associations[association.hash] = association
        end

        # Association Revise record
        def do_association_update(_parser, association)
          associations[association.hash] = association
        end

        # Association Delete record
        def do_association_delete(_parser, association)
          associations.delete association.hash
        end

        # New Train received
        def do_train_schedule_create(_parser, train_schedule)
          trains[train_schedule.uid] ||= []
          trains[train_schedule.uid].push train_schedule
        end

        # Revise Train received
        def do_train_schedule_update(parser, train_schedule)
          trains[train_schedule.uid] ||= []
          index = trains[train_schedule.uid].index train_schedule
          return do_train_schedule_create(parser, train_schedule) if index.nil?
          trains[train_schedule.uid][index] = train_schedule
        end

        # Delete Train record
        def do_train_schedule_delete(_parser, train_schedule)
          trains[train_schedule.uid]&.delete train_schedule
        end

        # Trailer record
        def do_trailer(_parser); end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
