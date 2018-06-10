module RailFeeds
  # A Class to store username & password
  # Can be used to set a global default but create new instances with
  # specific ones for a specific use.
  class Credentials
    attr_reader :username, :password

    @username = nil
    @password = nil

    def self.configure(username:, password:)
      @username = username.to_s.clone.freeze
      @password = password.to_s.clone.freeze
      nil
    end

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
