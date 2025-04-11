require 'spec_helper'
require 'sevenrooms/client'

RSpec.describe Sevenrooms::Client do
  let(:api_key) { 'test_key' }
  let(:api_url) { 'https://api.sevenrooms.com/2_4' }
  let(:client) { described_class.new(api_key: api_key, api_url: api_url) }

  describe '#initialize' do
    it 'initializes with an API key' do
      expect(client.api_key).to eq(api_key)
    end

    it 'uses default API URL if not provided' do
      client = described_class.new(api_key: api_key)
      expect(client.api_url).to eq(api_url)
    end

    it 'raises ConfigurationError if API key is missing' do
      expect { described_class.new(api_key: nil) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(api_key: '') }.to raise_error(Sevenrooms::ConfigurationError)
    end

    it 'raises ConfigurationError if API URL is missing' do
      expect { described_class.new(api_key: api_key, api_url: nil) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(api_key: api_key, api_url: '') }.to raise_error(Sevenrooms::ConfigurationError)
    end
  end

  describe '#create_booking' do
    let(:booking_params) { { name: 'John Doe', email: 'john@example.com' } }
    let(:response_body) { { id: '123', status: 'confirmed' } }

    before do
      stub_request(:post, "#{api_url}/reservations")
        .with(
          body: booking_params.to_json,
          headers: { 'Authorization' => "Bearer #{api_key}" }
        )
        .to_return(status: 200, body: response_body.to_json)
    end

    it 'creates a booking successfully' do
      response = client.create_booking(booking_params)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:post, "#{api_url}/reservations")
        .to_return(status: 401, body: { message: 'Unauthorized' }.to_json)

      expect { client.create_booking(booking_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#update_booking' do
    let(:reservation_id) { '123' }
    let(:update_params) { { name: 'Jane Doe' } }
    let(:response_body) { { id: reservation_id, status: 'updated' } }

    before do
      stub_request(:put, "#{api_url}/reservations/#{reservation_id}")
        .with(
          body: update_params.to_json,
          headers: { 'Authorization' => "Bearer #{api_key}" }
        )
        .to_return(status: 200, body: response_body.to_json)
    end

    it 'updates a booking successfully' do
      response = client.update_booking(reservation_id, update_params)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:put, "#{api_url}/reservations/#{reservation_id}")
        .to_return(status: 404, body: { message: 'Not Found' }.to_json)

      expect { client.update_booking(reservation_id, update_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#cancel_booking' do
    let(:reservation_id) { '123' }
    let(:cancel_params) { { reason: 'Customer request' } }
    let(:response_body) { { id: reservation_id, status: 'cancelled' } }

    before do
      stub_request(:delete, "#{api_url}/reservations/#{reservation_id}")
        .with(
          body: cancel_params.to_json,
          headers: { 'Authorization' => "Bearer #{api_key}" }
        )
        .to_return(status: 200, body: response_body.to_json)
    end

    it 'cancels a booking successfully' do
      response = client.cancel_booking(reservation_id, cancel_params)
      expect(response).to eq(response_body)
    end

    it 'cancels a booking without params' do
      stub_request(:delete, "#{api_url}/reservations/#{reservation_id}")
        .with(headers: { 'Authorization' => "Bearer #{api_key}" })
        .to_return(status: 200, body: response_body.to_json)

      response = client.cancel_booking(reservation_id)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:delete, "#{api_url}/reservations/#{reservation_id}")
        .to_return(status: 422, body: { message: 'Validation error' }.to_json)

      expect { client.cancel_booking(reservation_id, cancel_params) }.to raise_error(Sevenrooms::APIError)
    end
  end
end 