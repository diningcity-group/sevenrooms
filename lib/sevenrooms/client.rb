# frozen_string_literal: true

require "faraday"
require "json"

module Sevenrooms
  class Client
    attr_reader :client_id, :client_secret, :concierge_id, :api_url

    def initialize(client_id:, client_secret:, concierge_id:, api_url: "https://demo.sevenrooms.com/api-ext/2_4")
      @client_id = client_id
      @client_secret = client_secret
      @concierge_id = concierge_id
      @api_url = api_url
      validate_configuration!
    end

    def create_reservation(params)
      post("/reservations", params)
    end

    def update_reservation(reservation_id, params)
      put("/reservations/#{reservation_id}", params)
    end

    def cancel_reservation(reservation_id, params = {})
      delete("/reservations/#{reservation_id}", params)
    end

    def get_reservation(reservation_id)
      get("/reservations/#{reservation_id}")
    end

    private

    def connection
      @connection ||= Faraday.new(url: @api_url) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def put(path, params = {})
      request(:put, path, params)
    end

    def delete(path, params = {})
      request(:delete, path, params)
    end

    def request(method, path, params = {})
      response = connection.send(method) do |req|
        req.url path.start_with?('/') ? path[1..-1] : path
        req.headers["X-Client-Id"] = @client_id
        req.headers["X-Client-Secret"] = @client_secret
        req.headers["X-Concierge-Id"] = @concierge_id
        req.body = params.to_json if [:post, :put, :delete].include?(method) && !params.empty?
      end

      handle_response(response)
    end

    def handle_response(response)
      case response.status
      when 200..299
        symbolize_keys(response.body)
      when 401
        raise APIError, "Unauthorized: Invalid credentials"
      when 404
        raise APIError, "Resource not found"
      when 422
        raise APIError, "Validation error: #{response.body['message']}"
      else
        raise APIError, "Unexpected error: #{response.body['message']}"
      end
    end

    def symbolize_keys(hash)
      return hash unless hash.is_a?(Hash)
      hash.transform_keys(&:to_sym)
    end

    def validate_configuration!
      raise ConfigurationError, "Client ID is required" if @client_id.nil? || @client_id.empty?
      raise ConfigurationError, "Client Secret is required" if @client_secret.nil? || @client_secret.empty?
      raise ConfigurationError, "Concierge ID is required" if @concierge_id.nil? || @concierge_id.empty?
      raise ConfigurationError, "API URL is required" if @api_url.nil? || @api_url.empty?
    end
  end
end