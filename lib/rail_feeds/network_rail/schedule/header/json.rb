# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      module Header
        # A class to hole the information from the header row of a json file
        class JSON
          # @!attribute [rw] extracted_at
          #   @return [Time] When the BTD extract happened.
          # @!attribute [rw] sequence
          #   @return [Integer] Where this file appears in the sequence of extracts.
          # (Appears to be days since 2012-06-13)
          # @!attribute [r] start_date
          #   @return [Date] Infered from sequence

          attr_accessor :extracted_at, :sequence

          START_DATE = Date.new 2012, 6, 13
          private_constant :START_DATE

          def initialize(**attributes)
            attributes.each do |attribute, value|
              send "#{attribute}=", value
            end
          end

          # Initialize a new header from a JSON file line
          def self.from_json(line)
            data = ::JSON.parse(line)['JsonTimetableV1']
            metadata = data['Metadata']

            new(
              extracted_at: Time.strptime(data['timestamp'].to_s, '%s').utc,
              sequence: metadata['sequence']
            )
          end

          def start_date
            START_DATE + sequence.to_i
          end

          def <=>(other)
            hash <=> other&.hash
          end

          def hash
            sequence&.dup
          end

          # rubocop:disable Metrics/MethodLength
          def to_json(**opts)
            {
              'JsonTimetableV1' => {
                'classification' => 'public',
                'timestamp' => extracted_at.to_i,
                'owner' => 'Network Rail',
                'Sender' => {
                  'organisation': '',
                  'application' => 'NTROD',
                  'component' => 'SCHEDULE'
                },
                'Metadata' => {
                  'type' => 'full',
                  'sequence' => sequence
                }
              }
            }.to_json(**opts)
          end
          # rubocop:enable Metrics/MethodLength

          def to_s
            "Sequence #{sequence}, proabbly from #{start_date}."
          end
        end
      end
    end
  end
end
