# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      # A collection of methods for working with a days array.
      # Provides a days attribute to the class.
      module Days
        def self.included(base)
          base.extend ClassMethods
        end

        # @return [Array<Boolean, nil>] What days the record applies to
        # (Monday -> Sunday).
        def days
          @days ||= Array.new(7, nil)
        end

        # @param [Array<Boolean, nil>, #to_s] value What days the record applies to.
        # (Monday -> Sunday).
        def days=(value)
          value = days_from_cif(value) unless value.is_a?(Array)
          (0..6).each do |i|
            days[i] = value[i]&.&(true)
          end
          days
        end

        # Query if the record applies on Mondays
        # @return [Boolean, nil]
        def mondays?
          days[0]
        end

        # Query if the record applies on Tuesdays
        # @return [Boolean, nil]
        def tuesdays?
          days[1]
        end

        # Query if the record applies on Wednesdays
        # @return [Boolean, nil]
        def wednesdays?
          days[2]
        end

        # Query if the record applies on Thursdays
        # @return [Boolean, nil]
        def thursdays?
          days[3]
        end

        # Query if the record applies on Fridays
        # @return [Boolean, nil]
        def fridays?
          days[4]
        end

        # Query if the record applies on Saturdays
        # @return [Boolean, nil]
        def saturdays?
          days[5]
        end

        # Query if the record applies on Sundays
        # @return [Boolean, nil]
        def sundays?
          days[6]
        end

        protected

        def days_to_cif
          self.class.days_to_cif days
        end

        def days_from_cif(value)
          self.days = self.class.days_from_cif value
        end

        module ClassMethods # :nodoc:
          def days_to_cif(value)
            value.map { |d| d ? '1' : '0' }.join
          end

          def days_from_cif(value)
            return [nil, nil, nil, nil, nil, nil, nil] if value.nil?

            Array.new(7) { |i| value[i]&.eql?('1') }
          end
        end
        private_constant :ClassMethods
      end
    end
  end
end
