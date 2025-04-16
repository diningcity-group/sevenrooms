require 'spec_helper'
require 'sevenrooms/client'

RSpec.describe Sevenrooms::Client do
  let(:client_id) { '3716a4de80165423ca25964c9321f4f3742a6ec43482b8060f1be86f7d94e51c5e2db99d6435c4733eb102a7bc2e73df63b5d3cd5684e3e0a3fd4af383d47198' }
  let(:client_secret) { '3fb0fd43ab186f9fe6518c0bb3c49e7315a4900766452baf7a5afac8e17943aee318cf8d934f5630ada06ca141bdd9a3813fa9c24969b8e5f51acaf5350b8a0' }
  let(:concierge_id) { 'ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yIAsSE25pZ2h0bG9vcF9Db25jaWVyZ2UYgICY_PuXqwoM' }
  let(:api_url) { 'https://demo.sevenrooms.com/api-ext/2_4' }
  let(:client) { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: api_url) }

  before do
    # Stub authentication request
    stub_request(:post, "#{api_url}/auth")
      .with(
        body: {
          client_id: client_id,
          client_secret: client_secret
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            token: 'test_token',
            token_expiration_datetime: '2024-04-16T12:00:00Z'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub create reservation request
    stub_request(:put, "#{api_url}/concierge/#{concierge_id}/venues/venue123/book")
      .with(
        body: {
          venue_id: 'venue123',
          arrival_time: '07:00:00 PM',
          party_size: 4,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          phone: '123-456-7890',
          notes: 'Window seat preferred'
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'test_token',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            id: '12345',
            status: 'confirmed'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub update reservation request
    stub_request(:put, "#{api_url}/concierge/#{concierge_id}/reservations/123")
      .with(
        body: {
          first_name: 'Jane',
          last_name: 'Doe'
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'test_token',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            id: '123',
            status: 'confirmed'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub cancel reservation request
    stub_request(:delete, "#{api_url}/concierge/#{concierge_id}/reservations/123")
      .with(
        body: {
          reason: 'Customer request'
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'test_token',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            id: '123',
            status: 'cancelled'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub cancel reservation request without params
    stub_request(:delete, "#{api_url}/concierge/#{concierge_id}/reservations/123")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'test_token',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            id: '123',
            status: 'cancelled'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub get reservation request
    stub_request(:get, "#{api_url}/concierge/#{concierge_id}/reservations/123")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'test_token',
          'User-Agent' => 'Ruby',
          'X-Concierge-Id' => concierge_id
        }
      )
      .to_return(
        status: 200,
        body: {
          data: {
            id: '123',
            status: 'confirmed',
            arrival_time: '07:00:00 PM',
            party_size: 4
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '#initialize' do
    it 'initializes with credentials' do
      expect(client.client_id).to eq(client_id)
      expect(client.client_secret).to eq(client_secret)
      expect(client.concierge_id).to eq(concierge_id)
      expect(client.api_url).to eq(api_url)
    end

    it 'uses default API URL if api_url parameter is not provided' do
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

    it 'raises ConfigurationError if API URL is explicitly set to nil or empty' do
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: nil) }.to raise_error(Sevenrooms::ConfigurationError)
      expect { described_class.new(client_id: client_id, client_secret: client_secret, concierge_id: concierge_id, api_url: '') }.to raise_error(Sevenrooms::ConfigurationError)
    end
  end

  describe '#create_reservation' do
    let(:reservation_params) do
      {
        venue_id: 'venue123',
        arrival_time: '07:00:00 PM',
        party_size: 4,
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        phone: '123-456-7890',
        notes: 'Window seat preferred'
      }
    end

    it 'creates a reservation successfully' do
      response = client.create_reservation(reservation_params[:venue_id], reservation_params)
      expect(response['data']['id']).to eq('12345')
      expect(response['data']['status']).to eq('confirmed')
    end

    it 'handles API errors' do
      stub_request(:put, "#{api_url}/concierge/#{concierge_id}/venues/venue123/book")
        .to_return(status: 400, body: { message: 'Bad Request' }.to_json)

      expect { client.create_reservation(reservation_params[:venue_id], reservation_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#update_reservation' do
    let(:update_params) do
      {
        first_name: 'Jane',
        last_name: 'Doe'
      }
    end

    it 'updates a reservation successfully' do
      response = client.update_reservation('123', update_params)
      expect(response['data']['id']).to eq('123')
      expect(response['data']['status']).to eq('confirmed')
    end

    it 'handles API errors' do
      stub_request(:put, "#{api_url}/concierge/#{concierge_id}/reservations/123")
        .to_return(status: 400, body: { message: 'Bad Request' }.to_json)

      expect { client.update_reservation('123', update_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#cancel_reservation' do
    let(:cancel_params) do
      {
        reason: 'Customer request'
      }
    end

    it 'cancels a reservation successfully' do
      response = client.cancel_reservation('123', cancel_params)
      expect(response['data']['id']).to eq('123')
      expect(response['data']['status']).to eq('cancelled')
    end

    it 'cancels a reservation without params' do
      response = client.cancel_reservation('123')
      expect(response['data']['id']).to eq('123')
      expect(response['data']['status']).to eq('cancelled')
    end

    it 'handles API errors' do
      stub_request(:delete, "#{api_url}/concierge/#{concierge_id}/reservations/123")
        .to_return(status: 400, body: { message: 'Bad Request' }.to_json)

      expect { client.cancel_reservation('123', cancel_params) }.to raise_error(Sevenrooms::APIError)
    end
  end

  describe '#get_reservation' do
    it 'gets a reservation successfully' do
      response = client.get_reservation('123')
      expect(response['data']['id']).to eq('123')
      expect(response['data']['status']).to eq('confirmed')
      expect(response['data']['arrival_time']).to eq('07:00:00 PM')
      expect(response['data']['party_size']).to eq(4)
    end

    it 'handles API errors' do
      stub_request(:get, "#{api_url}/concierge/#{concierge_id}/reservations/123")
        .to_return(status: 400, body: { message: 'Bad Request' }.to_json)

      expect { client.get_reservation('123') }.to raise_error(Sevenrooms::APIError)
    end
  end
end 