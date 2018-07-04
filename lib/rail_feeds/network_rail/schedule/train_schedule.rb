# frozen_string_literal: true

require 'date'
require 'time'

require_relative 'train_schedule/change_en_route'
require_relative 'train_schedule/location'

module RailFeeds
  module NetworkRail
    module Schedule
      # rubocop:disable Metrics/ClassLength
      # A class for holding information about a particular train
      class TrainSchedule
        include Comparable
        include Schedule::Days
        include Schedule::STPIndicator

        # @!attribute [rw] uid
        #   @return [String] The unique train identifier (letter then 5 numbers).
        #   Along with start_date uniquely identifies a schedule.
        # @!attribute [rw] category
        #   @return [String]
        # @!attribute [rw] status
        #   @return [String]
        # @!attribute [rw] stp_indicator
        #   @return [String]
        #   * C - cancellation of permanent schedule
        #   * N - new STP schedule
        #   * O - STP overlay of permanent schedule
        #   * P - permanent
        # @!attribute [rw] portion_id
        #   @return [String, nil]
        #   Denotes a portion ID for services involved in splits/joins.
        # @!attribute [rw] reservation_headcode
        #   @return [Integer, nil] The train's headcode in the NRS
        #   (National Reservation System).
        # @!attribute [rw] signalling_headcode
        #   @return [String, nil] The headcode used in signalling the service.
        #   Will be nil for annonymous freight services.
        # @!attribute [rw] service_code
        #   @return [Integer] Used for attribution of revenue.
        # @!attribute [rw] start_date
        #   @return [Date] When the schedule starts.
        # @!attribute [rw] end_date
        #   @return [Date] When the schedule ends.
        # @!attribute [rw] days
        #   @return [Array<Boolean>] The days on which the service runs.
        #   [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
        # @!attribute [rw] run_on_bank_holiday
        #   @return [String, nil] Whether the service runs on bank holidays.
        #   * X - does not run on specified bank holiday Mondays.
        #   * G - does not run on Glasgow bank holidays.
        # @!attribute [rw] power_type
        #   @return [String]
        # @!attribute [rw] timing_load
        #   @return [String, nil]
        # @!attribute [rw] speed
        #   @return [Integer] The planned speed (miles per hour).
        # @!attribute [rw] operating_characteristics
        #   @return [String, nil]
        # @!attribute [rw] seating_class
        #   @return [String, nil] The seating classes available.
        #   * B or blank - First and Standard
        #   * S - Standard only
        # @!attribute [rw] sleeping_class
        #   @return [String, nil] The sleeping classes available.
        #   * B - First and Standard
        #   * F - First only
        #   * S - Standard only
        # @!attribute [rw] reservations
        #   @return [String, nil] The reservation recommendations.
        #   * A - Reservations Compulsory
        #   * E - Reservations for bicycles essential
        #   * R - Reservations recommended
        #   * S - Reservations possible from any station
        #   * W - Wheelchair only reservations
        # @!attribute [rw] catering
        #   @return [String, nil] The catering available, any 2 of:
        #   * H - Hot food available
        #   * C - Buffet service
        #   * R - Restaurant
        #   * F - Restaurant for first class passengers
        #   * M - Meal included for first class passengers
        #   * T - Trolly service
        # @!attribute [rw] branding
        #   @return [String, nil] The service brand.
        #   * E - Eurostar
        # @!attribute [rw] uic
        #   @return [Integer, nil] For train services running to/from continental Europe.
        # @!attribute [rw] atoc
        # @!attribute [rw] applicable_timetable
        #   @return [Boolean, nil] Whether the service is subject to
        #   performance monitoring (Applicable Timetable Service).
        # @!attribute [rw] journey
        #   @return [Array<Location, ChangeEnRoute>] The combined locations and changes.
        #   change will precede location.

        attr_accessor :uid, :category, :status, :portion_id,
                      :reservation_headcode, :signalling_headcode, :service_code,
                      :start_date, :end_date, :run_on_bank_holiday,
                      :power_type, :timing_load, :speed, :operating_characteristics,
                      :seating_class, :sleeping_class, :reservations, :catering,
                      :branding, :uic, :atoc, :applicable_timetable, :journey
        # Attributes from modules :days, :stp_indicator

        # Initialize a new train
        def initialize(**attributes)
          @journey = []
          attributes.each do |attribute, value|
            send "#{attribute}=", value
          end
        end

        # Add details from a CIF schedule file line to this train
        def update_from_cif(line)
          type = line[0..1]

          if type.eql?('BS')
            update_basic_information line
          elsif type.eql?('BX')
            update_extra_information line

          elsif %w[LO LI LT].include?(type)
            journey.push Location.from_cif(line)

          elsif type.eql?('CR')
            journey.push ChangeEnRoute.from_cif(line)

          else
            fail ArgumentError, "Improper line type #{line[0..1]}: #{line}"
          end
        end

        def to_cif
          [
            basic_to_cif,
            extra_to_cif,
            *journey.map(&:to_cif)
          ].join
        end

        def hash
          "#{uid}-#{start_date&.strftime('%Y%m%d')}"
        end

        def ==(other)
          hash == other&.hash
        end

        def <=>(other)
          values = [start_date, uid]
          other_values = [other&.start_date, other&.uid]
          values <=> other_values
        end

        private

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def update_basic_information(line)
          self.uid = line[3..8].strip
          self.start_date = Schedule.make_date line[9..14]
          self.end_date = Schedule.make_date line[15..20], allow_nil: line[2].eql?('D')
          self.days = days_from_cif line[21..27]
          self.run_on_bank_holiday = Schedule.nil_or_strip line[28]
          self.status = Schedule.nil_or_strip(line[29])
          self.category = Schedule.nil_or_strip(line[30..31])
          self.signalling_headcode = Schedule.nil_or_strip line[32..35]
          self.reservation_headcode = Schedule.nil_or_i line[36..39]
          self.service_code = Schedule.nil_or_i line[41..48]
          self.portion_id = Schedule.nil_or_strip line[49]
          self.power_type = Schedule.nil_or_strip(line[50..52])
          self.timing_load = Schedule.nil_or_strip line[53..56].strip
          self.speed = Schedule.nil_or_i(line[57..59])
          self.operating_characteristics = Schedule.nil_or_strip line[60..65].strip
          self.seating_class = Schedule.nil_or_strip line[66]
          self.sleeping_class = Schedule.nil_or_strip line[67]
          self.reservations = Schedule.nil_or_strip line[68]
          self.catering = Schedule.nil_or_strip(line[70..73])
          self.branding = Schedule.nil_or_strip line[74..77].strip
          self.stp_indicator = stp_indicator_from_cif line[79]
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def update_extra_information(line)
          self.uic = Schedule.nil_or_i line[6..10]
          self.atoc = line[11..12]
          self.applicable_timetable = line[13].eql?('Y')
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def basic_to_cif
          format('%-80.80s', [
            'BSN',
            format('%-6.6s', uid),
            # rubocop:disable Style/FormatStringToken
            format('%-6.6s', start_date&.strftime('%y%m%d')),
            format('%-6.6s', end_date&.strftime('%y%m%d')),
            # rubocop:enable Style/FormatStringToken
            days_to_cif,
            format('%-1.1s', run_on_bank_holiday),
            format('%-1.1s', status),
            format('%-2.2s', category),
            format('%-4.4s', signalling_headcode),
            format('%-4.4s', reservation_headcode),
            '1',
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
            ' ',
            stp_indicator_to_cif
          ].join) + "\n"
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        def extra_to_cif
          format('%-80.80s', [
            'BX    ',
            format('%-5.5s', uic),
            format('%-2.2s', atoc),
            format('%-1.1s', (applicable_timetable ? 'Y' : 'N'))
          ].join) + "\n"
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
