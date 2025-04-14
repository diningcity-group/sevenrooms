# frozen_string_literal: true

require_relative "sevenrooms/version"
require_relative "sevenrooms/client"
require_relative "sevenrooms/booking"
require_relative "sevenrooms/webhook"
require_relative "sevenrooms/reservation"

module Sevenrooms
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class APIError < Error; end

  class << self
    attr_accessor :client_id, :client_secret, :concierge_id, :api_url

    def configure
      yield self
    end

    def client
      @client ||= Client.new(
        client_id: client_id,
        client_secret: client_secret,
        concierge_id: concierge_id,
        api_url: api_url
      )
    end
  end
end
