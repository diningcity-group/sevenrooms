# frozen_string_literal: true

module Sevenrooms
  # @deprecated Use {Reservation} instead. This class will be removed in the next major version.
  # 
  # Migration Guide:
  # 1. Replace `Booking.new` with `Reservation.new`
  # 2. Update parameter names:
  #    - Use `arrival_time` instead of separate `date` and `time`
  #    - Format arrival_time as "HH:MM:SS AM/PM"
  # 3. Update method calls:
  #    - All methods now return standardized responses
  #    - Additional validation is performed on parameters
  #    - New methods available: get, list, and batch operations
  #
  # Example:
  #   # Old code:
  #   booking = Sevenrooms::Booking.new(client)
  #   booking.create(
  #     venue_id: "123",
  #     date: "2024-04-01",
  #     time: "7:00 PM",
  #     party_size: 4
  #   )
  #
  #   # New code:
  #   reservation = Sevenrooms::Reservation.new(client)
  #   reservation.create(
  #     venue_id: "123",
  #     arrival_time: "07:00:00 PM",
  #     party_size: 4
  #   )
  class Booking
    def initialize(client)
      warn "[DEPRECATION] `Booking` is deprecated. Please use `Reservation` instead."
      @client = client
    end

    # @deprecated Use {Reservation#create} instead
    def create(params)
      warn "[DEPRECATION] `create` is deprecated. Please use `Reservation#create` instead."
      validate_booking_params!(params)
      @client.create_booking(params)
    end

    # @deprecated Use {Reservation#update} instead
    def update(reservation_id, params)
      warn "[DEPRECATION] `update` is deprecated. Please use `Reservation#update` instead."
      validate_booking_params!(params)
      @client.update_booking(reservation_id, params)
    end

    # @deprecated Use {Reservation#cancel} instead
    def cancel(reservation_id, params = {})
      warn "[DEPRECATION] `cancel` is deprecated. Please use `Reservation#cancel` instead."
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