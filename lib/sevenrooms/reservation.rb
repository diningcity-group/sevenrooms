# frozen_string_literal: true

module Sevenrooms
  class Reservation
    attr_reader :id, :first_name, :last_name, :email, :phone, :party_size,
                :reservation_time, :venue_id, :status, :status_code, :reference_code,
                :client_requests, :booking_policy, :cancellation_policy, :client,
                :arrival_time, :booked_by, :created, :date, :external_id,
                :prepayment, :prepayment_total, :upgrades

    def initialize(attributes = {}, client = nil)
      if attributes.is_a?(Hash)
        @id = attributes['id'] || attributes[:id] || attributes['reservation_id'] || attributes[:reservation_id]
        @first_name = attributes['first_name'] || attributes[:first_name]
        @last_name = attributes['last_name'] || attributes[:last_name]
        @email = attributes['email'] || attributes[:email]
        @phone = attributes['phone_number'] || attributes[:phone]
        @party_size = attributes['max_guests'] || attributes[:party_size]
        @reservation_time = attributes['real_datetime_of_slot'] || attributes[:reservation_time]
        @venue_id = attributes['venue_id'] || attributes[:venue_id]
        @status = attributes['status'] || attributes[:status]
        @status_code = attributes['status_code'] || attributes[:status_code]
        @reference_code = attributes['reference_code'] || attributes[:reference_code]
        @client_requests = attributes['client_requests'] || attributes[:client_requests]
        @booking_policy = attributes['booking_policy'] || attributes[:booking_policy]
        @cancellation_policy = attributes['cancellation_policy'] || attributes[:cancellation_policy]
        @arrival_time = attributes['arrival_time'] || attributes[:arrival_time]
        @booked_by = attributes['booked_by'] || attributes[:booked_by]
        @created = attributes['created'] || attributes[:created]
        @date = attributes['date'] || attributes[:date]
        @external_id = attributes['external_id'] || attributes[:external_id]
        @prepayment = attributes['prepayment'] || attributes[:prepayment]
        @prepayment_total = attributes['prepayment_total'] || attributes[:prepayment_total]
        @upgrades = attributes['upgrades'] || attributes[:upgrades]
        @client = client
      else
        @client = attributes
      end
    end

    def create(params)
      validate_create_params!(params)
      response = @client.create_reservation(params[:venue_id], params)
      self.class.new(response['data'], @client)
    end

    def update(params)
      validate_update_params!(params)
      response = @client.update_reservation(@id, params)
      self.class.new(response['data'], @client)
    end

    def cancel(reason = nil)
      params = reason ? { cancellation_reason: reason } : {}
      response = @client.cancel_reservation(@id, params)
      self.class.new(response['data'], @client)
    end

    def get(reservation_id)
      response = @client.get_reservation(reservation_id)
      self.class.new(response['data'], @client)
    end

    def to_h
      {
        arrival_time: @arrival_time,
        party_size: @party_size,
        reservation_id: @id,
        status: @status
      }
    end

    private

    def validate_create_params!(params)
      # Validate required parameters
      validate_required_params!(params)

      # Validate party size
      validate_party_size!(params[:party_size])

      # Validate time format if present
      validate_time_format!(params[:arrival_time]) if params[:arrival_time]

      # Validate email format if present
      validate_email_format!(params[:email]) if params[:email]

      # Validate phone format if present
      validate_phone_format!(params[:phone]) if params[:phone]
    end

    def validate_required_params!(params)
      required_params = [:venue_id, :arrival_time, :party_size]
      missing_params = required_params.select { |param| params[param].nil? || params[param].to_s.empty? }
      
      if missing_params.any?
        raise ArgumentError, "Missing required parameters: #{missing_params.join(', ')}"
      end
    end

    def validate_party_size!(party_size)
      return unless party_size
      
      unless party_size.is_a?(Integer) && party_size.positive?
        raise ArgumentError, 'Party size must be a positive integer'
      end
    end

    def validate_time_format!(time)
      return unless time
      
      unless time.match?(/^\d{2}:\d{2}:\d{2}\s+(AM|PM)$/i)
        raise ArgumentError, "Time must be in format 'HH:MM:SS AM/PM'"
      end
    end

    def validate_phone_format!(phone)
      return unless phone
      
      unless phone.match?(/^\+?[\d\s\-\(\)]+$/)
        raise ArgumentError, 'Invalid phone number format'
      end
    end

    def validate_email_format!(email)
      return unless email
      
      unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
        raise ArgumentError, 'Invalid email format'
      end
    end

    def validate_update_params!(params)
      return if params.empty?
      
      # Validate party size if present
      validate_party_size!(params[:party_size]) if params[:party_size]

      # Validate time format if present
      validate_time_format!(params[:arrival_time]) if params[:arrival_time]

      # Validate email format if present
      validate_email_format!(params[:email]) if params[:email]

      # Validate phone format if present
      validate_phone_format!(params[:phone]) if params[:phone]
    end
  end
end 