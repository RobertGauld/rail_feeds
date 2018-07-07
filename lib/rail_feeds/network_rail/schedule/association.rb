# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      # rubocop:disable Metrics/ClassLength
      # A class for holding information about an association between many trains.
      class Association
        include Comparable
        include Schedule::Days
        include Schedule::STPIndicator

        # @!attribute [rw] main_train_uid
        #   @return [String] The UID of the main train in the association.
        # @!attribute [rw] associated_train_uid
        #   @return [String] The UID of the associated train in the association.
        # @!attribute [rw] category
        #   @return [String] The category of the association:
        #   * JJ - join
        #   * VV - divide
        #   * NP - next
        # @!attribute [rw] start_date
        #   @return [Date] When the schedule starts.
        # @!attribute [rw] end_date
        #   @return [Date] When the schedule ends.
        # @!attribute [rw] date_indicator
        #   @return [String] When the assocation happens:
        #   * S - same day
        #   * N - over next midnight
        #   * P - over previous midnight
        # @!attribute [rw] days
        #   @return [Array<Boolean>] The days on which the service runs.
        #   [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
        # @!attribute [rw] tiploc
        #   @return [String] The TIPLOC of the location the association occurs.
        # @!attribute [rw] base_location_suffix
        #   @return [String, nil]
        #   Together with the tiploc uniquely identifies the association
        #   on the base_uid.
        # @!attribute [rw] associated_location_suffix
        #   @return [String, nil]
        #   Together with the tiploc uniquely identifies the association
        #   on the associated_uid.
        # @!attribute [rw] stp_indicator
        #   @return [String]
        #   * C - cancellation of permanent schedule
        #   * N - new STP schedule
        #   * O - STP overlay of permanent schedule
        #   * P - permanent

        attr_accessor :main_train_uid, :associated_train_uid, :category,
                      :start_date, :end_date, :date_indicator,
                      :tiploc, :main_location_suffix, :associated_location_suffix
        # Attributes from modules :days, :stp_indicator

        def initialize(**attributes)
          attributes.each do |attribute, value|
            send "#{attribute}=", value
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # Initialize a new association from a CIF file line
        def self.from_cif(line)
          unless %w[AAN AAR AAD].include?(line[0..2])
            fail ArgumentError, "Invalid line:\n#{line}"
          end

          new(
            main_train_uid: line[3..8].strip,
            associated_train_uid: line[9..14].strip,
            start_date: Schedule.make_date(line[15..20]),
            end_date: Schedule.make_date(line[21..26], allow_nil: line[2].eql?('D')),
            days: days_from_cif(line[27..33]),
            category: Schedule.nil_or_strip(line[34..35]),
            date_indicator: Schedule.nil_or_strip(line[36]),
            tiploc: line[37..43].strip,
            main_location_suffix: Schedule.nil_or_i(line[44]),
            associated_location_suffix: Schedule.nil_or_i(line[45]),
            stp_indicator: stp_indicator_from_cif(line[79])
          )
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/AbcSize
        # Initialize a new association from a JSON file line
        def self.from_json(line)
          data = ::JSON.parse(line)['JsonAssociationV1']

          new(
            main_train_uid: data['main_train_uid'],
            associated_train_uid: data['assoc_train_uid'],
            start_date: Date.parse(data['assoc_start_date']),
            end_date: data['assoc_end_date'] ? Date.parse(data['assoc_end_date']) : nil,
            days: days_from_cif(data['assoc_days']),
            category: Schedule.nil_or_strip(data['category']),
            date_indicator: Schedule.nil_or_strip(data['date_indicator']),
            tiploc: data['location'],
            main_location_suffix: Schedule.nil_or_i(data['base_location_suffix']),
            associated_location_suffix: Schedule.nil_or_i(data['assoc_location_suffix']),
            stp_indicator: stp_indicator_from_cif(data['CIF_stp_indicator'])
          )
        end
        # rubocop:enable Metrics/AbcSize

        # Test if this is a join association.
        def join?
          category.eql?('JJ')
        end

        # Test if this is a divide association.
        def divide?
          category.eql?('VV')
        end

        # Test if this is a next association.
        def next?
          category.eql?('NP')
        end

        # Test if the association happens on the same day.
        def same_day?
          date_indicator.eql?('S')
        end

        # Test if the association happens over the next midnight.
        def over_next_midnight?
          date_indicator.eql?('N')
        end

        # Test if the association happens over the previous midnight.
        def over_previous_midnight?
          date_indicator.eql?('P')
        end

        # Uniquely identifies the event on the main_train_uid
        def main_train_event_id
          "#{tiploc}-#{main_location_suffix}"
        end

        # Uniquely identifies the event on the associated_train_uid
        def associated_train_event_id
          "#{tiploc}-#{associated_location_suffix}"
        end

        def ==(other)
          main_train_event_id == other&.main_train_event_id &&
            associated_train_event_id == other&.associated_train_event_id
        end

        def <=>(other)
          start_date <=> other&.start_date
        end

        def hash
          "#{tiploc}-#{main_location_suffix}-#{associated_location_suffix}"
        end

        # rubocop:disable Metrics/AbcSize
        def to_cif
          format('%-80.80s', [
            'AAN',
            format('%-6.6s', main_train_uid),
            format('%-6.6s', associated_train_uid),
            # rubocop:disable Style/FormatStringToken
            format('%-6.6s', start_date&.strftime('%y%m%d')),
            format('%-6.6s', end_date&.strftime('%y%m%d')),
            # rubocop:enable Style/FormatStringToken
            days_to_cif,
            format('%-2.2s', category),
            format('%-1.1s', date_indicator),
            format('%-7.7s', tiploc),
            format('%-1.1s', main_location_suffix),
            format('%-1.1s', associated_location_suffix),
            'T                                ',
            stp_indicator_to_cif
          ].join) + "\n"
        end
        # rubocop:enable Metrics/AbcSize

        # rubocop:disable Metrics/MethodLength
        def to_json
          {
            'JsonAssociationV1' => {
              'transaction_type' => 'Create',
              'main_train_uid' => main_train_uid,
              'assoc_train_uid' => associated_train_uid,
              'assoc_start_date' => start_date.strftime('%Y-%m-%dT00:00:00Z'),
              'assoc_end_date' => end_date.strftime('%Y-%m-%dT00:00:00Z'),
              'assoc_days' => days_to_cif,
              'category' => category,
              'date_indicator' => date_indicator,
              'location' => tiploc,
              'base_location_suffix' => main_location_suffix,
              'assoc_location_suffix' => associated_location_suffix,
              'diagram_type' => 'T',
              'CIF_stp_indicator' => stp_indicator_to_cif
            }
          }.to_json
        end
        # rubocop:enable Metrics/MethodLength
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
