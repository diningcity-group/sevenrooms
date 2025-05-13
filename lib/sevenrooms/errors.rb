module Sevenrooms
  class Error < StandardError; end
  class APIError < Error; end
  class ConfigurationError < Error; end
  class AvailabilityError < Error; end
end 