# frozen_string_literal: true

require 'spec_helper'
require 'sevenrooms/reservation'

RSpec.describe Sevenrooms::Reservation do
  let(:client) { instance_double(Sevenrooms::Client) }
  let(:reservation) { described_class.new({ id: '12345' }, client) }
  let(:reservation_id) { '12345' }

  describe '#create' do
    let(:valid_params) do
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
      expect(client).to receive(:create_reservation).with(valid_params[:venue_id], valid_params)
        .and_return({ 'data' => { id: '12345', status: 'confirmed' } })
      
      result = reservation.create(valid_params)
      expect(result).to be_a(described_class)
      expect(result.id).to eq('12345')
    end

    it 'validates required parameters' do
      required_params = [:venue_id, :arrival_time, :party_size]
      required_params.each do |param|
        invalid_params = valid_params.dup
        invalid_params.delete(param)
        
        expect do
          reservation.create(invalid_params)
        end.to raise_error(ArgumentError, /Missing required parameters:.*#{param}/)
      end
    end

    it 'validates party size is a positive integer' do
      invalid_params = valid_params.merge(party_size: -1)
      
      expect do
        reservation.create(invalid_params)
      end.to raise_error(ArgumentError, 'Party size must be a positive integer')
    end

    it 'validates time format' do
      invalid_params = valid_params.merge(arrival_time: 'invalid time')
      
      expect do
        reservation.create(invalid_params)
      end.to raise_error(ArgumentError, 'Time must be in format \'HH:MM:SS AM/PM\'')
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:create_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.create(valid_params)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#update' do
    let(:valid_params) do
      {
        first_name: 'Jane',
        last_name: 'Doe'
      }
    end

    it 'updates a reservation successfully' do
      expect(client).to receive(:update_reservation).with(reservation_id, valid_params)
        .and_return({ 'data' => { id: reservation_id, status: 'confirmed' } })
      
      result = reservation.update(valid_params)
      expect(result).to be_a(described_class)
      expect(result.id).to eq(reservation_id)
    end

    it 'validates party size is a positive integer' do
      invalid_params = { party_size: 'invalid' }
      
      expect do
        reservation.update(invalid_params)
      end.to raise_error(ArgumentError, 'Party size must be a positive integer')
    end

    it 'validates time format' do
      invalid_params = { arrival_time: 'invalid' }
      
      expect do
        reservation.update(invalid_params)
      end.to raise_error(ArgumentError, 'Time must be in format \'HH:MM:SS AM/PM\'')
    end

    it 'allows partial updates' do
      expect(client).to receive(:update_reservation).with(reservation_id, { first_name: 'Jane' })
        .and_return({ 'data' => { id: reservation_id, status: 'confirmed' } })
      
      result = reservation.update({ first_name: 'Jane' })
      expect(result).to be_a(described_class)
    end

    it 'handles empty update parameters' do
      expect(client).to receive(:update_reservation).with(reservation_id, {})
        .and_return({ 'data' => { id: reservation_id, status: 'confirmed' } })
      
      result = reservation.update({})
      expect(result).to be_a(described_class)
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:update_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.update(valid_params)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#cancel' do
    it 'cancels a reservation successfully' do
      expect(client).to receive(:cancel_reservation).with(reservation_id, {})
        .and_return({ 'data' => { id: reservation_id, status: 'cancelled' } })
      
      result = reservation.cancel
      expect(result).to be_a(described_class)
      expect(result.id).to eq(reservation_id)
    end

    it 'cancels with optional parameters' do
      expect(client).to receive(:cancel_reservation).with(reservation_id, { cancellation_reason: 'test' })
        .and_return({ 'data' => { id: reservation_id, status: 'cancelled' } })
      
      result = reservation.cancel('test')
      expect(result).to be_a(described_class)
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:cancel_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.cancel
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#get' do
    it 'retrieves a reservation successfully' do
      expected_response = {
        arrival_time: '07:00:00 PM',
        party_size: 4,
        reservation_id: '12345',
        status: 'confirmed'
      }

      expect(client).to receive(:get_reservation).with(reservation_id)
        .and_return({ 'data' => expected_response })
      
      result = reservation.get(reservation_id)
      expect(result).to be_a(described_class)
      expect(result.to_h).to eq(expected_response)
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:get_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.get(reservation_id)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end
end 