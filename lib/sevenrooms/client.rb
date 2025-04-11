# frozen_string_literal: true

require "faraday"
require "json"

module Sevenrooms
  class Client
    def initialize(api_key:, api_url: "https://api.sevenrooms.com/2_4")
      @api_key = api_key
      @api_url = api_url
      validate_configuration!
    end

    def create_booking(params)
      post("/reservations", params)
    end

    def update_booking(reservation_id, params)
      put("/reservations/#{reservation_id}", params)
    end

    def cancel_booking(reservation_id, params = {})
      delete("/reservations/#{reservation_id}", params)
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
        req.url path
        req.headers["Authorization"] = "Bearer #{@api_key}"
        req.body = params.to_json if [:post, :put].include?(method)
      end

      handle_response(response)
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 401
        raise APIError, "Unauthorized: Invalid API key"
      when 404
        raise APIError, "Resource not found"
      when 422
        raise APIError, "Validation error: #{response.body['message']}"
      else
        raise APIError, "Unexpected error: #{response.body['message']}"
      end
    end

    def validate_configuration!
      raise ConfigurationError, "API key is required" if @api_key.nil? || @api_key.empty?
      raise ConfigurationError, "API URL is required" if @api_url.nil? || @api_url.empty?
    end
  end
end