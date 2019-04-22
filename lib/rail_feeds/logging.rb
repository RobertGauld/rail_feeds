# frozen_string_literal: true

module RailFeeds
  # A Module to provide a global logger
  module Logging
    def self.included(base)
      class << base
        # Provide a logger 'attribute' to a class which defaults to the class logger.
        def logger
          @logger || Logging.logger
        end

        # rubocop:disable Style/TrivialAccessors
        def logger=(logger)
          @logger = logger
        end
        # rubocop:enable Style/TrivialAccessors
      end
    end

    # Provide a logger attribute to an instance which defaults to the global logger.
    def logger
      @logger || self.class.logger
    end

    def logger=(logger)
      @logger = logger
    end

    # Global, memoized, lazy initialized instance of a logger
    def self.logger
      @logger ||= Logger.new(
        STDOUT,
        formatter: formatter,
        level: Logger::DEBUG
      )
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.formatter
      proc do |severity, datetime, progname, message|
        "#{datetime} #{"#{progname} " unless progname.nil?}#{severity}: #{message}\n"
      end
    end
  end
end
