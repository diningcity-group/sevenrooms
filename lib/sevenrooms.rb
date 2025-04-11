# frozen_string_literal: true

require_relative "sevenrooms/version"
# require_relative "sevenrooms/client"
require_relative "sevenrooms/booking"
# require_relative "sevenrooms/webhook"

module Sevenrooms
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class APIError < Error; end

  class << self
    attr_accessor :api_key, :api_url

    def configure
      yield self
    end

    def client
      @client ||= Client.new(api_key: api_key, api_url: api_url)
    end
  end
end
