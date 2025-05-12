# frozen_string_literal: true

require "json"


module Sevenrooms
  class Webhook
    def initialize(secret_key)
      @secret_key = secret_key
    end

    def verify_signature(payload, signature)
      expected_signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new("sha256"),
        @secret_key,
        payload
      )

      signature == expected_signature
    end

    def parse_event(payload)
      JSON.parse(payload)
    rescue JSON::ParserError => e
      raise Error, "Invalid JSON payload: #{e.message}"
    end

    def handle_event(payload, signature)
      raise Error, "Invalid signature" unless verify_signature(payload, signature)

      event = parse_event(payload)
      process_event(event)
    end

    private

    def process_event(event)
      case event["type"]
      when "reservation.created"
        handle_reservation_created(event)
      when "reservation.updated"
        handle_reservation_updated(event)
      when "reservation.cancelled"
        handle_reservation_cancelled(event)
      else
        # Handle unknown event types
        nil
      end
    end

    def handle_reservation_created(event)
      # Implement your logic for handling reservation creation
      event
    end

    def handle_reservation_updated(event)
      # Implement your logic for handling reservation updates
      event
    end

    def handle_reservation_cancelled(event)
      # Implement your logic for handling reservation cancellations
      event
    end
  end
end
