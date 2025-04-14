# frozen_string_literal: true

module Sevenrooms
  class Reservation
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def create(params)
      validate_create_params!(params)
      client.post("/reservations", params)
    end

    def update(reservation_id, params)
      validate_update_params!(params)
      client.put("/reservations/#{reservation_id}", params)
    end

    def cancel(reservation_id, params = {})
      client.delete("/reservations/#{reservation_id}", params)
    end

    def get(reservation_id)
      client.get("/reservations/#{reservation_id}")
    end

    def list(params = {})
    # @option params [Integer] :limit Number of results to return (1-400)
    # @return [Hash] List of reservations
    def list(params = {})
      client.get("/reservations", params)
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