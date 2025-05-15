# frozen_string_literal: true

module Sevenrooms
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class APIError < Error; end
  class AvailabilityError < Error; end
end 