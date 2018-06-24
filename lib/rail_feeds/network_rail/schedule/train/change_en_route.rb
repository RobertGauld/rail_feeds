# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class Train
        # A class for holding information about a particular train's change en route
        class ChangeEnRoute
          # @!attribute [rw] tiploc
          #   @return [String] The location where the change occurs.
          # @!attribute [rw] tiploc_suffix
          #   @return [String]
          # @!attribute [rw] category
          #   @return [String] The train's new category.
          # @!attribute [rw] signalling_headcode
          #   @return [String, nil] The train's new signalling_headcode.
          # @!attribute [rw] reservation_headcode
          #   @return [Integer, nil] The train's new reservation_headcode.
          # @!attribute [rw] service_code
          #   @return [String] The train's new service_code.
          # @!attribute [rw] portion_id
          #   @return [String, nil] The train's new portion_id.
          # @!attribute [rw] power_type
          #   @return [String] The train's new power_type.
          # @!attribute [rw] timing_load
          #   @return [String, nil] The train's new timing_load.
          # @!attribute [rw] speed
          #   @return [Integer] The train's new speed.
          # @!attribute [rw] operating_characteristics
          #   @return [String, nil] The train's new operating_characteristics.
          # @!attribute [rw] seating_class
          #   @return [String, nil] The train's new seating_class.
          # @!attribute [rw] sleeping_class
          #   @return [String, nil] The train's new sleeping_class.
          # @!attribute [rw] reservations
          #   @return [String, nil] The train's new reservations.
          # @!attribute [rw] catering
          #   @return [String, nil] The train's new catering.
          # @!attribute [rw] branding
          #   @return [String, nil] The train's new branding.
          # @!attribute [rw] uic_code
          #   @return [Integer, nil] The train's new uic_code.

          attr_accessor :tiploc, :tiploc_suffix, :category, :signalling_headcode,
                        :reservation_headcode, :service_code, :portion_id, :power_type,
                        :timing_load, :speed, :operating_characteristics,
                        :seating_class, :sleeping_class, :reservations, :catering,
                        :branding, :uic_code

          def initialize(**attributes)
            attributes.each do |attribute, value|
              send "#{attribute}=", value
            end
          end

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          # Initialize a new change en route from a CIF file line
          def self.from_cif(line)
            fail ArgumentError, "Invalid line:\n#{line}" unless line[0..1].eql?('CR')

            new(
              tiploc: line[2..8].strip,
              tiploc_suffix: line[9].to_i,
              category: line[10..11].strip,
              signalling_headcode: line[12..15].strip,
              reservation_headcode: Schedule.nil_or_i(line[16..19]),
              service_code: Schedule.nil_or_i(line[21..28]),
              portion_id: Schedule.nil_or_strip(line[29]),
              power_type: line[30..32].strip,
              timing_load: Schedule.nil_or_strip(line[33..36]),
              speed: Schedule.nil_or_i(line[37..39]),
              operating_characteristics: line[40..45].strip,
              seating_class: Schedule.nil_or_strip(line[46]),
              sleeping_class: Schedule.nil_or_strip(line[47]),
              reservations: Schedule.nil_or_strip(line[48]),
              catering: line[50..53].strip,
              branding: Schedule.nil_or_strip(line[54..57]),
              uic_code: Schedule.nil_or_strip(line[62..66])
            )
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          # Apply these changes to a train.
          # @param [RailFeeds::NetworkRail::Schedule::Train] train
          #   The train to apply the changes to.
          # @return [RailFeeds::NetworkRail::Schedule::Train]
          #   The train the changes were applied to.
          def apply_to(train)
            train.category = category
            train.signalling_headcode = signalling_headcode
            train.reservation_headcode = reservation_headcode
            train.service_code = service_code
            train.portion_id = portion_id
            train.power_type = power_type
            train.timing_load = timing_load
            train.speed = speed
            train.operating_characteristics = operating_characteristics
            train.seating_class = seating_class
            train.sleeping_class = sleeping_class
            train.reservations = reservations
            train.catering = catering
            train.branding = branding
            train.uic_code = uic_code
            train
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          def ==(other)
            hash == other&.hash
          end

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          def to_cif
            format('%-80.80s', [
              'CR',
              format('%-7.7s', tiploc),
              format('%-1.1s', tiploc_suffix),
              format('%-2.2s', category),
              format('%-4.4s', signalling_headcode),
              format('%-4.4s', reservation_headcode),
              ' ',
              format('%-8.8s', service_code),
              format('%-1.1s', portion_id),
              format('%-3.3s', power_type),
              format('%-4.4s', timing_load),
              format('%-3.3s', speed),
              format('%-6.6s', operating_characteristics),
              format('%-1.1s', seating_class),
              format('%-1.1s', sleeping_class),
              format('%-1.1s', reservations),
              ' ',
              format('%-4.4s', catering),
              format('%-4.4s', branding),
              '    ',
              format('%-5.5s', uic_code)
            ].join) + "\n"
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          def hash
            "#{tiploc}-#{tiploc_suffix}"
          end
        end
      end
    end
  end
end
