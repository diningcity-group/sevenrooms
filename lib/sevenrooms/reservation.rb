# frozen_string_literal: true

module Sevenrooms
  class Reservation
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # Create a new reservation
    # @param params [Hash] Reservation parameters
    # @option params [String] :venue_id The venue ID
    # @option params [String] :client_id The client ID
    # @option params [String] :arrival_time The arrival time (format: "HH:MM:SS AM/PM")
    # @option params [Integer] :party_size Number of guests
    # @option params [String] :first_name First name of the guest
    # @option params [String] :last_name Last name of the guest
    # @option params [String] :email Email address
    # @option params [String] :phone Phone number
    # @option params [String] :notes Additional notes
    # @return [Hash] The created reservation
    def create(params)
      validate_create_params!(params)
      client.create_reservation(params)
    end

    # Update an existing reservation
    # @param reservation_id [String] The reservation ID
    # @param params [Hash] Update parameters
    # @option params [String] :arrival_time The new arrival time (format: "HH:MM:SS AM/PM")
    # @option params [Integer] :party_size New party size
    # @option params [String] :notes Updated notes
    # @return [Hash] The updated reservation
    def update(reservation_id, params)
      validate_update_params!(params)
      client.update_reservation(reservation_id, params)
    end

    # Cancel a reservation
    # @param reservation_id [String] The reservation ID
    # @param params [Hash] Cancellation parameters
    # @option params [String] :cancellation_reason Reason for cancellation
    # @return [Hash] The cancelled reservation
    def cancel(reservation_id, params = {})
      client.cancel_reservation(reservation_id, params)
    end

    # Get a reservation by ID
    # @param reservation_id [String] The reservation ID
    # @return [Hash] The reservation details
    def get(reservation_id)
      client.get_reservation(reservation_id)
    end

    private

    def validate_create_params!(params)
      required_params = [:venue_id, :client_id, :arrival_time, :party_size]
      missing_params = required_params - params.keys
      if missing_params.any?
        raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}"
      end

      validate_party_size!(params[:party_size])
      validate_time_format!(params[:arrival_time])
    end

    def validate_update_params!(params)
      return if params.empty?
      
      validate_party_size!(params[:party_size]) if params[:party_size]
      validate_time_format!(params[:arrival_time]) if params[:arrival_time]
    end

    def validate_party_size!(party_size)
      return unless party_size
      unless party_size.is_a?(Integer) && party_size.positive?
        raise ArgumentError, "Party size must be a positive integer"
      end
    end

    def validate_time_format!(time)
      return unless time
      unless time.match?(/^\d{1,2}:\d{2}:\d{2}\s[AP]M$/)
        raise ArgumentError, "Time must be in format 'HH:MM:SS AM/PM'"
      end
    end
  end
end 