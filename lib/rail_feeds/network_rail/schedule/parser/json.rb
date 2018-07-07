# frozen_string_literal: true

require 'json'

module RailFeeds
  module NetworkRail
    module Schedule
      class Parser
        # A class for parsing schedule data read from JSON schedule file(s).
        class JSON < Parser
          def parse_line(line)
            if line.start_with? '{"TiplocV1":'
              parse_tiploc_line line
            elsif line.start_with? '{"JsonAssociationV1":'
              parse_association_line line
            elsif line.start_with? '{"JsonScheduleV1":'
              parse_schedule_line line
            elsif line.start_with? '{"JsonTimetableV1":'
              parse_header_line line
            elsif line.start_with? '{"EOF":'
              parse_trailer_line line
            else
              logger.error "Can't understand line: #{line.chomp}"
            end
          end

          private

          def parse_header_line(line)
            header = Header.from_json(line)
            logger.info "Starting Parse. #{header}"
            @on_header&.call self, header
          end

          def parse_trailer_line(_line)
            @file_ended = true
            @on_trailer&.call self
          end

          def parse_tiploc_line(line)
            hash = ::JSON.parse(line)['TiplocV1']

            case hash['transaction_type'].downcase
            when 'create'
              @on_tiploc_create&.call self, Tiploc.from_json(line)
            when 'update'
              fail 'no idea what this hash looks like'
            when 'delete'
              @on_tiploc_delete&.call self, hash['tiploc_code']
            else
              logger.error 'Don\'t know how to ' \
                           "#{hash['transaction_type'].inspect} a Tiploc: #{line.chomp}"
            end
          end

          def parse_association_line(line)
            hash = ::JSON.parse(line)['JsonAssociationV1']

            case hash['transaction_type'].downcase
            when 'create'
              @on_association_create&.call self, Association.from_json(line)
            when 'delete'
              @on_association_delete&.call self, Association.from_json(line)
            else
              logger.error 'Don\'t know how to ' \
                           "#{hash['transaction_type'].inspect} an Association: " \
                           "#{line.chomp}"
            end
          end

          def parse_schedule_line(line)
            hash = ::JSON.parse(line)['JsonScheduleV1']

            case hash['transaction_type'].downcase
            when 'create'
              @on_train_schedule_create&.call self, TrainSchedule.from_json(line)
            when 'delete'
              @on_train_schedule_delete&.call self, TrainSchedule.from_json(line)
            else
              logger.error 'Don\'t know how to ' \
                           "#{hash['transaction_type'].inspect} a Train Schedule: " \
                           "#{line.chomp}"
            end
          end
        end
      end
    end
  end
end
