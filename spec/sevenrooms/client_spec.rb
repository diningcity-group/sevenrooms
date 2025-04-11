require 'spec_helper'
require 'sevenrooms/client'

RSpec.describe Sevenrooms::Client do
  let(:client_id) { '3716a4de80165423ca25964c9321f4f3742a6ec43482b8060f1be86f7d94e51c5e2db99d6435c4733eb102a7bc2e73df63b5d3cd5684e3e0a3fd4af383d47198' }
  let(:client_secret) { '3fb0fd43ab186f9fe6518c0bb3c49e7315a4900766452baf7a5afac8e17943aee318cf8d934f5630ada06ca141bdd9a3813fa9c24969b8e5f51acaf5350b8a0' }
  let(:concierge_id) { 'ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yIAsSE25pZ2h0bG9vcF9Db25jaWVyZ2UYgICY_PuXqwoM' }
  let(:api_url) { 'https://demo.sevenrooms.com/api-ext/2_4' }
  let(:client) { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: api_url) }

  describe '#initialize' do
    it 'initializes with credentials' do
      expect(client.client_id).to eq(client_id)
      expect(client.client_secret).to eq(client_secret)
      expect(client.concierge_id).to eq(concierge_id)
      expect(client.api_url).to eq(api_url)
    end

    it 'uses default API URL if not provided' do
      client = described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id)
      expect(client.api_url).to eq(api_url)
    end

    it 'raises ConfigurationError if client_id is missing' do
      expect { described_class.new(client_id: nil, client_secret: client_secret, concierge_id: concierge_id) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(client_id: '', client_secret: client_secret, concierge_id: concierge_id) }.to raise_error(Sevenrooms::ConfigurationError)
    end

    it 'raises ConfigurationError if client_secret is missing' do
      expect { described_class.new(client_id: client_id, client_secret: nil, concierge_id: concierge_id) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(client_id: client_id, client_secret: '', concierge_id: concierge_id) }.to raise_error(Sevenrooms::ConfigurationError)
    end

    it 'raises ConfigurationError if concierge_id is missing' do
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: nil) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: '') }.to raise_error(Sevenrooms::ConfigurationError)
    end

    it 'raises ConfigurationError if API URL is missing' do
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: nil) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: '') }.to raise_error(Sevenrooms::ConfigurationError)
    end
  end

  describe '#create_booking' do
    let(:booking_params) { { venue_id: '123', date: '2024-04-15', time: '19:00', party_size: 2, first_name: 'John', last_name: 'Doe', email: 'john@example.com' } }
    let(:response_body) { { id: '123', status: 'confirmed' } }

    before do
      stub_request(:post, "#{api_url}/reservations")
        .with(
          body: booking_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'creates a booking successfully' do
      response = client.create_booking(booking_params)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:post, "#{api_url}/reservations")
        .with(
          body: booking_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 401, body: { message: 'Unauthorized' }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { client.create_booking(booking_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#update_booking' do
    let(:reservation_id) { '123' }
    let(:update_params) { { first_name: 'Jane', last_name: 'Doe' } }
    let(:response_body) { { id: reservation_id, status: 'updated' } }

    before do
      stub_request(:put, "#{api_url}/reservations/#{reservation_id}")
        .with(
          body: update_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'updates a booking successfully' do
      response = client.update_booking(reservation_id, update_params)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:put, "#{api_url}/reservations/#{reservation_id}")
        .with(
          body: update_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 404, body: { message: 'Not Found' }.to_json, headers: { 'Content-Type' => 'application/json' })

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
          body: cancel_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'cancels a booking successfully' do
      response = client.cancel_booking(reservation_id, cancel_params)
      expect(response).to eq(response_body)
    end

    it 'cancels a booking without params' do
      stub_request(:delete, "#{api_url}/reservations/#{reservation_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      response = client.cancel_booking(reservation_id)
      expect(response).to eq(response_body)
    end

    it 'handles API errors' do
      stub_request(:delete, "#{api_url}/reservations/#{reservation_id}")
        .with(
          body: cancel_params,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.13.0',
            'X-Client-Id' => client_id,
            'X-Client-Secret' => client_secret,
            'X-Concierge-Id' => concierge_id
          }
        )
        .to_return(status: 422, body: { message: 'Validation error' }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { client.cancel_booking(reservation_id, cancel_params) }.to raise_error(Sevenrooms::APIError)
    end
  end
end 