# frozen_string_literal: true

module RailFeeds
  module NetworkRail
    module Schedule
      class Parser
        # A class for parsing schedule data read from CIF schedule file(s).
        class CIF < Parser
          UNDERSTOOD_ROWS = %w[
            HD TI TA TD AAN AAD AAR BSN BSD BSR BX LO LI LT CR ZZ
          ].freeze

          # Parse the data on a single CIF line
          # @param [String] line
          def parse_line(line)
            catch :line_parsed do
              UNDERSTOOD_ROWS.each do |record_type|
                if line.start_with?(record_type)
                  send "parse_#{record_type.downcase}_line", line.chomp
                  throw :line_parsed
                end
              end

              if line[0].eql?('/')
                parse_comment_line line.chomp
                throw :line_parsed
              end

              logger.error "Can't understand line: #{line.chomp.inspect}"
            end
          end

          private

          # Header record
          def parse_hd_line(line)
            header = Header.from_cif(line)
            logger.info "Starting Parse. #{header}"
            @on_header&.call self, header
          end

          # TIPLOC Insert record
          def parse_ti_line(line)
            @on_tiploc_insert&.call self, Tiploc.from_cif(line)
          end

          # TIPLOC Amend record
          def parse_ta_line(line)
            tiploc = Tiploc.from_cif(line)
            old_id = tiploc.tiploc
            tiploc.tiploc = line[2..8].strip
            @on_tiploc_amend&.call self, old_id, tiploc
          end

          # TIPLOC Delete record
          def parse_td_line(line)
            @on_tiploc_delete&.call self, Tiploc.from_cif(line).tiploc
          end

          # Association New record
          def parse_aan_line(line)
            @on_association_new&.call self, Association.from_cif(line)
          end

          # Association Revise record
          def parse_aar_line(line)
            @on_association_revise&.call self, Association.from_cif(line)
          end

          # Association Delete record
          def parse_aad_line(line)
            @on_association_delete&.call self, Association.from_cif(line)
          end

          # Train schedule record - basic schedule - new
          def parse_bsn_line(line)
            finish_current_train
            @current_train = TrainSchedule.new
            @current_train.update_from_cif line
            @current_train_action = :new
          end

          # Train schedule record - basic schedule - delete
          def parse_bsd_line(line)
            finish_current_train
            train = TrainSchedule.new
            train.update_from_cif line
            @on_train_schedule_delete&.call self, train
          end

          # Train schedule record - basic schedule - revise
          def parse_bsr_line(line)
            finish_current_train
            @current_train = TrainSchedule.new
            @current_train.update_from_cif line
            @current_train_action = :revise
          end

          # Train schedule record - basic schedule extra details
          def parse_bx_line(line)
            @current_train.update_from_cif line
          end

          # Train schedule record - origin location
          alias parse_lo_line parse_bx_line
          # Train schedule record - intermediate location
          alias parse_li_line parse_bx_line
          # Train schedule record - change en route
          alias parse_cr_line parse_bx_line
          # Train schedule record - terminating location
          alias parse_lt_line parse_bx_line

          def finish_current_train
            return if @current_train.nil?

            case @current_train_action
            when :new
              @on_train_schedule_new&.call self, @current_train
            when :revise
              @on_train_schedule_revise&.call self, @current_train
            end

            @current_train = nil
          end

          # Trailer record
          def parse_zz_line(_line)
            finish_current_train
            @file_ended = true
            @on_trailer&.call self
          end

          # Comment
          def parse_comment_line(line)
            @on_comment&.call self, line[1..-1]
          end
        end
      end
    end
  end
end
