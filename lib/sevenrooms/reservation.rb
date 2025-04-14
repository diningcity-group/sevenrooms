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

    # Create multiple reservations in a batch
    # @param reservations [Array<Hash>] Array of reservation parameters
    # @return [Array<Hash>] Array of created reservations or errors
    def create_batch(reservations)
      reservations.map do |params|
        begin
          create(params)
        rescue Sevenrooms::APIError => e
          e
        end
      end
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

    # Update multiple reservations in a batch
    # @param updates [Array<Hash>] Array of update parameters
    # @option updates [String] :reservation_id The reservation ID
    # @option updates [Hash] :params Update parameters
    # @return [Array<Hash>] Array of updated reservations or errors
    def update_batch(updates)
      updates.map do |update|
        begin
          update(update[:reservation_id], update[:params])
        rescue Sevenrooms::APIError => e
          e
        end
      end
    end

    # Cancel a reservation
    # @param reservation_id [String] The reservation ID
    # @param params [Hash] Cancellation parameters
    # @option params [String] :cancellation_reason Reason for cancellation
    # @return [Hash] The cancelled reservation
    def cancel(reservation_id, params = {})
      client.cancel_reservation(reservation_id, params)
    end

    # Cancel multiple reservations in a batch
    # @param cancellations [Array<Hash>] Array of cancellation parameters
    # @option cancellations [String] :reservation_id The reservation ID
    # @option cancellations [Hash] :params Cancellation parameters
    # @return [Array<Hash>] Array of cancelled reservations or errors
    def cancel_batch(cancellations)
      cancellations.map do |cancellation|
        begin
          cancel(cancellation[:reservation_id], cancellation[:params])
        rescue Sevenrooms::APIError => e
          e
        end
      end
    end

    # Get a reservation by ID
    # @param reservation_id [String] The reservation ID
    # @return [Hash] The reservation details
    def get(reservation_id)
      client.get_reservation(reservation_id)
    end

    # Get multiple reservations by IDs
    # @param reservation_ids [Array<String>] Array of reservation IDs
    # @return [Array<Hash>] Array of reservation details or errors
    def get_batch(reservation_ids)
      reservation_ids.map do |id|
        begin
          get(id)
        rescue Sevenrooms::APIError => e
          e
        end
      end
    end

    # List reservations with optional filters
    # @param params [Hash] Filter parameters
    # @option params [String] :venue_id Filter by venue ID
    # @option params [String] :from_date Filter by start date (YYYY-MM-DD)
    # @option params [String] :to_date Filter by end date (YYYY-MM-DD)
    # @option params [String] :status Filter by reservation status
    # @option params [Integer] :limit Number of results to return (1-400)
    # @option params [Integer] :page Page number for pagination
    # @return [Hash] List of reservations with pagination info
    def list(params = {})
      validate_list_params!(params)
      client.list_reservations(params)
    end

    # List all reservations with pagination
    # @param params [Hash] Filter parameters
    # @yield [Hash] Block to process each page of results
    # @return [void]
    def list_all(params = {}, &block)
      page = 1
      loop do
        response = list(params.merge(page: page))
        yield response if block_given?
        
        break if response[:results].empty? || !response[:has_more]
        page += 1
      end
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

    def validate_list_params!(params)
      return if params.empty?

      if params[:limit] && (params[:limit] < 1 || params[:limit] > 400)
        raise ArgumentError, "Limit must be between 1 and 400"
      end

      if params[:page] && params[:page] < 1
        raise ArgumentError, "Page must be a positive integer"
      end

      if params[:from_date] && !valid_date_format?(params[:from_date])
        raise ArgumentError, "from_date must be in format YYYY-MM-DD"
      end

      if params[:to_date] && !valid_date_format?(params[:to_date])
        raise ArgumentError, "to_date must be in format YYYY-MM-DD"
      end
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

    def valid_date_format?(date)
      date.match?(/^\d{4}-\d{2}-\d{2}$/)
    end
  end
end 