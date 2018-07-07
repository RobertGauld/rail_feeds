# frozen_string_literal: true

require_relative 'parser/cif'
require_relative 'parser/json'

module RailFeeds
  module NetworkRail
    module Schedule
      # A parent class for parsing schedule data read from schedule file(s).
      # Children need to implement a parse_line method.
      class Parser
        include Logging

        # rubocop:disable Metrics/ParameterLists
        # Initialize a new data.
        # @param [Logger, nil] logger
        #   The logger for outputting events, if nil the global logger will be used.
        # @param [Proc, #call] on_header
        #   The proc to call when the header is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::Header.
        # @param [Proc, #call] on_tiploc_insert
        #   The proc to call when a tiploc insertion is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::Tiploc::Insert.
        # @param [Proc, #call] on_tiploc_amend
        #   The proc to call when an amendment to an existing tiploc is received.
        #   Passes self, tiploc_id and a RailFeeds::NetworkRail::Schedule::Tiploc::Ammend.
        # @param [Proc, #call] on_tiploc_delete
        #   The proc to call when an existing tiploc should be deleted.
        #   Passes self and a tiploc_id.
        # @param [Proc, #call] on_association_new
        #   The proc to call when a new association is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::Association.
        # @param [Proc, #call] on_association_revise
        #   The proc to call when a revision to an existing association is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::Association.
        # @param [Proc, #call] on_association_delete
        #   The proc to call when an existing association should be deleted.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::Association.
        # @param [Proc, #call] on_train_schedule_new
        #   The proc to call when a new train schedule is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::TrainSchedule::New.
        # @param [Proc, #call] on_train_schedule_revise
        #   The proc to call when a revision to an existing train schedule is received.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::TrainSchedule::Revise.
        # @param [Proc, #call] on_train_schedule_delete
        #   The proc to call when an existing train schedule should be deleted.
        #   Passes self and a RailFeeds::NetworkRail::Schedule::TrainSchedule::Delete.
        # @param [Proc, #call] on_trailer
        #   The proc to call when the trailer (end of file record) is received.
        #   Passes self.
        # @param [Proc, #call] on_comment
        #   The proc to call when a comment is received.
        #   Passes self and a String.
        def initialize(
          logger: nil,
          on_header: nil, on_trailer: nil, on_comment: nil,
          on_tiploc_insert: nil, on_tiploc_amend: nil, on_tiploc_delete: nil,
          on_association_new: nil, on_association_revise: nil,
          on_association_delete: nil, on_train_schedule_new: nil,
          on_train_schedule_revise: nil, on_train_schedule_delete: nil
        )
          self.logger = logger unless logger.nil?
          @on_header = on_header
          @on_trailer = on_trailer
          @on_tiploc_insert = on_tiploc_insert
          @on_tiploc_amend = on_tiploc_amend
          @on_tiploc_delete = on_tiploc_delete
          @on_association_new = on_association_new
          @on_association_revise = on_association_revise
          @on_association_delete = on_association_delete
          @on_train_schedule_new = on_train_schedule_new
          @on_train_schedule_revise = on_train_schedule_revise
          @on_train_schedule_delete = on_train_schedule_delete
          @on_comment = on_comment
        end
        # rubocop:enable Metrics/ParameterLists

        # Parse the data in CIF file.
        # @param [IO] file
        #   The file to load data from.
        def parse_file(file)
          @file_ended = false
          @stop_parsing = false

          file.each_line do |line|
            parse_line line

            if @stop_parsing
              logger.debug "Parsing of file #{file} was stopped."
              break
            end
          end

          fail "File is incomplete. #{file}" unless @stop_parsing || @file_ended
        end

        def parse_line(_line)
          fail 'parse_file MUST be implemented in the child class.'
        end

        # Stop parsing the current file.
        def stop_parsing
          @stop_parsing = true
        end
      end
    end
  end
end
