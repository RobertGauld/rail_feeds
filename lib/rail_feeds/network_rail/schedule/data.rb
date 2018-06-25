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
        # @return [Array<RailFeeds::NetworkRail::Schedule::Association>]
        # @!attribute [r] tiplocs
        # @return [Array<RailFeeds::NetworkRail::Schedule::Tiploc>]
        # @!attribute [r] trains
        # @return [Array<RailFeeds::NetworkRail::Schedule::Train>]

        attr_accessor :last_header, :associations, :tiplocs, :trains

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # Initialize a new data.
        # @param [Logger, nil] logger
        #   The logger for outputting events, if nil the global logger is used.
        def initialize(logger: nil)
          self.logger = logger unless logger.nil?
          @parser = Parser.new(
            logger: logger,
            on_header: proc { |*args| do_header(*args) },
            on_trailer: proc { |*args| do_trailer(*args) },
            on_tiploc_insert: proc { |*args| do_tiploc_insert(*args) },
            on_tiploc_amend: proc { |*args| do_tiploc_amend(*args) },
            on_tiploc_delete: proc { |*args| do_tiploc_delete(*args) },
            on_association_new: proc { |*args| do_association_new(*args) },
            on_association_revise: proc { |*args| do_association_revise(*args) },
            on_association_delete: proc { |*args| do_association_delete(*args) },
            on_train_new: proc { |*args| do_train_new(*args) },
            on_train_revise: proc { |*args| do_train_revise(*args) },
            on_train_delete: proc { |*args| do_train_delete(*args) }
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
          tiplocs.sort.each { |tiploc| yield tiploc.to_cif }
          associations.sort.each { |association| yield association.to_cif }
          trains.sort.each { |train| train.to_cif.each_line { |line| yield line } }
          yield "ZZ#{' ' * 78}\n"
          yield "/!! End of file\n"
        end
        # rubocop:enable Metrics/AbcSize

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

        # Inplace sort the various data arrays
        def sort!
          associations.sort!
          tiplocs.sort!
          trains.sort!
        end

        private

        def reset_data
          @last_header = nil
          @associations = []
          @tiplocs = []
          @trains = []
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
        def do_tiploc_insert(_parser, tiploc)
          tiplocs.push tiploc
        end

        # TIPLOC Amend record
        def do_tiploc_amend(parser, tiploc_id, tiploc)
          index = tiplocs.index do |t|
            t.tiploc.eql?(tiploc_id)
          end

          if index.nil?
            do_tiploc_insert parser, tiploc
          else
            tiplocs[index] = tiploc
          end
        end

        # TIPLOC Delete record
        def do_tiploc_delete(_parser, tiploc)
          tiplocs.delete tiploc
        end

        # Association New record
        def do_association_new(_parser, association)
          associations.push association
        end

        # Association Revise record
        def do_association_revise(parser, association)
          index = associations.index(association)
          if index.nil?
            do_association_new parser, association
          else
            associations[index] = association
          end
        end

        # Association Delete record
        def do_association_delete(_parser, association)
          associations.delete association
        end

        # New Train received
        def do_train_new(_parser, train)
          trains.push train
        end

        # Revise Train received
        def do_train_revise(parser, train)
          index = trains.index(train)
          if index.nil?
            do_train_new parser, train
          else
            trains[index] = train
          end
        end

        # Delete Train record
        def do_train_delete(_parser, train)
          trains.delete train
        end

        # Trailer record
        def do_trailer(_parser); end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
