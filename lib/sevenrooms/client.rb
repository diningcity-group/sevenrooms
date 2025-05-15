# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Sevenrooms
  class ConfigurationError < StandardError; end
  class APIError < StandardError; end
  class AvailabilityError < StandardError; end

  class Client
    attr_reader :client_id, :client_secret, :concierge_id, :api_url

    def initialize(client_id:, client_secret:, concierge_id: nil, api_url: nil)
      puts "\n[SevenRooms] Initializing client..."
      puts "[SevenRooms] API URL: #{api_url}"
      puts "[SevenRooms] Concierge ID: #{concierge_id}"

      @client_id = client_id
      @client_secret = client_secret
      @concierge_id = concierge_id
      @api_url = api_url || "https://api.sevenrooms.com/api-ext/v2"
      @retried_auth = nil

      # Validate configuration
      validate_configuration!

      authenticate!
    end

    def create_reservation(venue_id, params)
      puts "\n[SevenRooms] Creating reservation..."
      puts "[SevenRooms] Venue ID: #{venue_id}"

      @last_method = :create_reservation
      @last_args = [venue_id, params]

      # Convert reservation_time to date and time if present
      if params[:reservation_time]
        require 'date'
        reservation_time = DateTime.parse(params[:reservation_time])
        params[:date] = reservation_time.strftime('%Y-%m-%d')
        params[:time] = reservation_time.strftime('%H:%M')
        params.delete(:reservation_time)
      end

      # Format phone number to E.164 format
      if params[:phone]
        params[:phone] = format_phone_number(params[:phone])
      end

      request_url = "#{@api_url}/concierge/#{concierge_id}/venues/#{venue_id}/book"

      puts '[SevenRooms] Create Reservation Request Details:'
      puts '[SevenRooms] Method: PUT'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"
      puts "[SevenRooms] Body: #{params.inspect}"

      response = make_request(:put, request_url, params)
      handle_response(response)
    end

    def update_reservation(reservation_id, params)
      puts "\n[SevenRooms] Updating reservation..."
      puts "[SevenRooms] Reservation ID: #{reservation_id}"

      @last_method = :update_reservation
      @last_args = [reservation_id, params]

      request_url = "#{@api_url}/concierge/#{concierge_id}/reservations/#{reservation_id}"

      puts '[SevenRooms] Update Reservation Request Details:'
      puts '[SevenRooms] Method: PUT'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"
      puts "[SevenRooms] Body: #{params.inspect}"

      response = make_request(:put, request_url, params)
      handle_response(response)
    end

    def cancel_reservation(reservation_id, params = {})
      puts "\n[SevenRooms] Canceling reservation..."
      puts "[SevenRooms] Reservation ID: #{reservation_id}"

      @last_method = :cancel_reservation
      @last_args = [reservation_id, params]

      request_url = "#{@api_url}/concierge/#{concierge_id}/reservations/#{reservation_id}"

      puts '[SevenRooms] Cancel Reservation Request Details:'
      puts '[SevenRooms] Method: DELETE'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"
      puts "[SevenRooms] Body: #{params.inspect}"

      response = make_request(:delete, request_url, params)
      handle_response(response)
    end

    def get_reservation(reservation_id)
      puts "\n[SevenRooms] Getting reservation..."
      puts "[SevenRooms] Reservation ID: #{reservation_id}"

      @last_method = :get_reservation
      @last_args = [reservation_id]

      request_url = "#{@api_url}/concierge/#{concierge_id}/reservations/#{reservation_id}"

      puts '[SevenRooms] Get Reservation Request Details:'
      puts '[SevenRooms] Method: GET'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"

      response = make_request(:get, request_url)
      handle_response(response)
    end

    def request_reservation(venue_id, params)
      puts "\n[SevenRooms] Requesting reservation..."
      puts "[SevenRooms] Venue ID: #{venue_id}"

      @last_method = :request_reservation
      @last_args = [venue_id, params]

      request_url = "#{@api_url}/concierge/#{concierge_id}/venues/#{venue_id}/request"

      puts '[SevenRooms] Request Reservation Details:'
      puts '[SevenRooms] Method: PUT'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"
      puts "[SevenRooms] Body: #{params.inspect}"

      response = make_request(:put, request_url, params)
      handle_response(response)
    end

    def get_venue_availability(venue_id, params)
      puts "\n[SevenRooms] Getting venue availability..."
      puts "[SevenRooms] Venue ID: #{venue_id}"

      @last_method = :get_venue_availability
      @last_args = [venue_id, params]

      request_url = "#{@api_url}/concierge/#{concierge_id}/venues/#{venue_id}/availability/dining"

      puts '[SevenRooms] Get Venue Availability Request Details:'
      puts '[SevenRooms] Method: GET'
      puts "[SevenRooms] URL: #{request_url}"
      puts "[SevenRooms] Headers: #{default_headers.inspect}"
      puts "[SevenRooms] Params: #{params.inspect}"

      response = make_request(:get, request_url, params)
      handle_response(response)
    end

    private

    def authenticate!
      puts "\n[SevenRooms] Authenticating..."
      puts "[SevenRooms] Using client ID: #{client_id}"
      puts "[SevenRooms] API URL: #{@api_url}"

      auth_url = "#{@api_url}/auth"
      auth_headers = default_headers
      auth_body = {
        client_id: client_id,
        client_secret: client_secret
      }

      puts '[SevenRooms] Authentication Request Details:'
      puts '[SevenRooms] Method: POST'
      puts "[SevenRooms] Full URL: #{auth_url}"
      puts "[SevenRooms] Headers: #{auth_headers.inspect}"
      puts "[SevenRooms] Body: #{auth_body.inspect}"

      begin
        puts "[SevenRooms] Making request to: #{auth_url}"
        response = make_request(:post, auth_url, auth_body)

        puts '[SevenRooms] Raw Response:'
        puts "[SevenRooms] Status: #{response.code}"
        puts "[SevenRooms] Headers: #{response.to_hash.inspect}"
        puts "[SevenRooms] Body: #{response.body.inspect}"

        handle_response(response)

        if response.code == '200'
          body = JSON.parse(response.body)
          if body['data'] && body['data']['token']
            @token = body['data']['token']
            puts '[SevenRooms] Authentication successful'
            puts '[SevenRooms] Token received and stored'
            puts "[SevenRooms] Token expiration: #{body['data']['token_expiration_datetime']}"
          else
            puts '[SevenRooms] Authentication failed: No token in response'
            raise APIError, 'Authentication failed: No token in response'
          end
        else
          puts "[SevenRooms] Authentication failed: #{response.body}"
          raise APIError, "Authentication failed: #{response.body}"
        end
      rescue StandardError => e
        puts "[SevenRooms] Error during authentication: #{e.message}"
        puts "[SevenRooms] Error Class: #{e.class}"
        raise APIError, "Error during authentication: #{e.message}"
      end
    end

    def make_request(method, url, body = nil)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      case method
      when :get
        request = Net::HTTP::Get.new(uri.request_uri)
      when :post
        request = Net::HTTP::Post.new(uri.request_uri)
      when :put
        request = Net::HTTP::Put.new(uri.request_uri)
      when :delete
        request = Net::HTTP::Delete.new(uri.request_uri)
      end

      # Set headers
      default_headers.each { |key, value| request[key] = value }

      # Set body if present
      if body
        request['Content-Type'] = 'application/x-www-form-urlencoded'
        request.body = URI.encode_www_form(body)
      end

      # Make the request
      http.request(request)
    end

    def default_headers
      headers = {
        'X-Concierge-Id' => concierge_id
      }
      headers['Authorization'] = @token if @token
      headers
    end

    def handle_response(response)
      puts "\n[SevenRooms] Handling response..."
      puts "[SevenRooms] Status: #{response.code}"
      puts "[SevenRooms] Body: #{response.body.inspect}"

      body = JSON.parse(response.body)

      case response.code.to_i
      when 200..299
        puts '[SevenRooms] Request successful'
        body
      when 400
        error_message = body['msg'] || body['message'] || 'Unknown error'
        puts "[SevenRooms] Error: Bad Request - #{error_message}"
        raise APIError, "Bad Request: #{error_message}"
      when 401
        puts '[SevenRooms] Unauthorized - Token may have expired'
        if @retried_auth.nil?
          puts '[SevenRooms] Attempting to re-authenticate...'
          @retried_auth = true
          authenticate!
          puts '[SevenRooms] Retrying original request...'
          send(@last_method, *@last_args)
        else
          puts '[SevenRooms] Re-authentication failed'
          raise APIError, "Unauthorized: #{body['msg'] || body['message']}"
        end
      when 403
        puts "[SevenRooms] Error: Forbidden - #{body['msg'] || body['message']}"
        raise APIError, "Forbidden: #{body['msg'] || body['message']}"
      when 404
        puts "[SevenRooms] Error: Not Found - #{body['msg'] || body['message']}"
        raise APIError, "Not Found: #{body['msg'] || body['message']}"
      when 405
        puts "[SevenRooms] Error: Method Not Allowed - #{body['msg'] || body['message']}"
        raise APIError, "Method Not Allowed: #{body['msg'] || body['message']}"
      when 422
        puts "[SevenRooms] Error: Unprocessable Entity - #{body['msg'] || body['message']}"
        raise APIError, "Unprocessable Entity: #{body['msg'] || body['message']}"
      when 429
        puts "[SevenRooms] Error: Too Many Requests - #{body['msg'] || body['message']}"
        raise APIError, "Too Many Requests: #{body['msg'] || body['message']}"
      when 500..599
        puts "[SevenRooms] Error: Server Error - #{body['msg'] || body['message']}"
        raise APIError, "Server Error: #{body['msg'] || body['message']}"
      else
        puts "[SevenRooms] Error: Unexpected Error - #{body['msg'] || body['message']}"
        raise APIError, "Unexpected Error: #{body['msg'] || body['message']}"
      end
    end

    def validate_configuration!
      puts "\n[SevenRooms] Validating configuration..."
      raise ConfigurationError, 'client_id is required' if @client_id.nil? || @client_id.empty?
      raise ConfigurationError, 'client_secret is required' if @client_secret.nil? || @client_secret.empty?
      raise ConfigurationError, 'concierge_id is required' if @concierge_id.nil? || @concierge_id.empty?
      raise ConfigurationError, 'api_url is required' if @api_url.nil? || @api_url.empty?

      puts '[SevenRooms] Configuration validation successful'
    end

    def format_phone_number(phone)
      # Remove all non-digit characters except +
      digits = phone.gsub(/[^\d+]/, '')
      
      # If the number already has a + prefix, return as is
      return digits if digits.start_with?('+')
      
      # If the number starts with a country code (e.g., 852 for Hong Kong)
      if digits.length >= 10
        # Add + prefix
        "+#{digits}"
      else
        # If we can't determine the country code, raise an error
        raise ArgumentError, "Invalid phone number format. Please include country code (e.g., +852 for Hong Kong, +1 for US/Canada)"
      end
    end
  end
end
