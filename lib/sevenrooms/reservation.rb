# frozen_string_literal: true

module Sevenrooms
  class Reservation
    attr_reader :id, :first_name, :last_name, :email, :phone, :party_size,
                :reservation_time, :venue_id, :status, :status_code, :reference_code,
                :client_requests, :booking_policy, :cancellation_policy, :client,
                :arrival_time, :booked_by, :created, :date, :external_id,
                :prepayment, :prepayment_total, :upgrades

    def initialize(attributes = {}, client = nil)
      @id = attributes['id']
      @first_name = attributes['first_name']
      @last_name = attributes['last_name']
      @email = attributes['email']
      @phone = attributes['phone_number']
      @party_size = attributes['max_guests']
      @reservation_time = attributes['real_datetime_of_slot']
      @venue_id = attributes['venue_id']
      @status = attributes['status']
      @status_code = attributes['status_code']
      @reference_code = attributes['reference_code']
      @client_requests = attributes['client_requests']
      @booking_policy = attributes['booking_policy']
      @cancellation_policy = attributes['cancellation_policy']
      @arrival_time = attributes['arrival_time']
      @booked_by = attributes['booked_by']
      @created = attributes['created']
      @date = attributes['date']
      @external_id = attributes['external_id']
      @prepayment = attributes['prepayment']
      @prepayment_total = attributes['prepayment_total']
      @upgrades = attributes['upgrades']
      @client = client
    end

    def self.create(venue_id, params, client)
      response = client.create_reservation(venue_id, params)
      new(response['data'], client)
    end

    def self.find(reservation_id, client)
      response = client.get_reservation(reservation_id)
      new(response['data'], client)
    end

    def self.request(venue_id, params, client)
      response = client.request_reservation(venue_id, params)
      new(response['data'], client)
    end

    def update(params)
      response = client.update_reservation(id, params)
      initialize(response['data'], client)
      self
    end

    def cancel(reason = nil)
      params = reason ? { cancellation_reason: reason } : {}
      response = client.cancel_reservation(id, params)
      @status = 'CANCELED'
      @status_code = 'CANCELED'
      self
    end

    def to_h
      {
        id: id,
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone: phone,
        party_size: party_size,
        reservation_time: reservation_time,
        venue_id: venue_id,
        status: status,
        status_code: status_code,
        reference_code: reference_code,
        client_requests: client_requests,
        booking_policy: booking_policy,
        cancellation_policy: cancellation_policy,
        arrival_time: arrival_time,
        booked_by: booked_by,
        created: created,
        date: date,
        external_id: external_id,
        prepayment: prepayment,
        prepayment_total: prepayment_total,
        upgrades: upgrades
      }
    end

    private

    def validate_create_params!(params)
      # Validate required parameters
      validate_required_params!(params)
      validate_party_size!(params[:party_size])
      validate_date_format!(params[:date])
      validate_time_format!(params[:time])
      validate_phone_format!(params[:phone]) if params[:phone]
      validate_email_format!(params[:email]) if params[:email]
    end

    def validate_required_params!(params)
      # Check base required params
      required_base_params = [:date, :time, :party_size]
      missing_base_params = required_base_params - params.keys
      if missing_base_params.any?
        raise ArgumentError, "Missing required parameters: #{missing_base_params.join(', ')}"
      end

      # Check identification params
      has_name = params[:first_name] && params[:last_name]
      has_client_id = params[:client_id]
      has_external_id = params[:external_user_id]

      unless has_name || has_client_id || has_external_id
        raise ArgumentError, "Must provide either first_name and last_name, client_id, or external_user_id"
      end

      if params[:first_name] && !params[:last_name]
        raise ArgumentError, "last_name is required when first_name is provided"
      end

      if params[:last_name] && !params[:first_name]
        raise ArgumentError, "first_name is required when last_name is provided"
      end
    end

    def validate_update_params!(params)
      return if params.empty?
      
      validate_party_size!(params[:party_size]) if params[:party_size]
      validate_date_format!(params[:date]) if params[:date]
      validate_time_format!(params[:time]) if params[:time]
      validate_phone_format!(params[:phone]) if params[:phone]
      validate_email_format!(params[:email]) if params[:email]
    end

    def validate_party_size!(party_size)
      return unless party_size
      unless party_size.is_a?(Integer) && party_size.positive?
        raise ArgumentError, "Party size must be a positive integer"
      end
    end

    def validate_date_format!(date)
      return unless date
      unless date.match?(/^\d{4}-\d{2}-\d{2}$/)
        raise ArgumentError, "Date must be in YYYY-MM-DD format"
      end
    end

    def validate_time_format!(time)
      return unless time
      unless time.match?(/^\d{2}:\d{2}$/)
        raise ArgumentError, "Time must be in HH:MM format"
      end
    end

    def validate_phone_format!(phone)
      return unless phone
      unless phone.match?(/^\+[1-9]\d{1,14}$/)
        raise ArgumentError, "Phone must be in E.164 format (e.g., +12125551234)"
      end
    end

    def validate_email_format!(email)
      return unless email
      unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
        raise ArgumentError, "Invalid email format"
      end
    end
  end
end 