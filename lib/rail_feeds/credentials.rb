# frozen_string_literal: true

module RailFeeds
  # A Class to store username & password
  # Can be used to set a global default but create new instances with
  # specific ones for a specific use.
  class Credentials
    # @!attribute [r] username
    #   @return [String] The username to use for authentication.
    # @!attribute [r] password
    #   @return [String] The password to use for authentication.
    attr_reader :username, :password

    @username = nil
    @password = nil

    # Configure default credentials.
    # @param [String] username
    #   The username to use for authentication.
    # @param [String] password
    #   The password to use for authentication.
    def self.configure(username:, password:)
      @username = username.to_s.clone.freeze
      @password = password.to_s.clone.freeze
      nil
    end

    # Initialize a new cresential.
    def initialize(
        username: self.class.username,
        password: self.class.password
      )
      @username = username.to_s.clone
      @password = password.to_s.clone
    end

    def self.username
      @username.clone
    end

    def self.password
      @password.clone
    end
  end
end
