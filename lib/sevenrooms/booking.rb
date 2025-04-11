# frozen_string_literal: true

module Sevenrooms
  class Booking
    def initialize(client)
      @client = client
    end

    def create(params)
      validate_booking_params!(params)
      @client.create_booking(params)
    end

    def update(reservation_id, params)
      validate_booking_params!(params)
      @client.update_booking(reservation_id, params)
    end

    def cancel(reservation_id, params = {})
      @client.cancel_booking(reservation_id, params)
    end

    private

    def validate_booking_params!(params)
      required_fields = %w[venue_id date time party_size first_name last_name email]
      missing_fields = required_fields - params.keys.map(&:to_s)
      
      if missing_fields.any?
        raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
      end
    end
  end
end