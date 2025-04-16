# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sevenrooms::Reservation do
  let(:client) { instance_double(Sevenrooms::Client) }
  let(:reservation) { described_class.new(client) }
  let(:reservation_id) { '12345' }

  describe '#create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          venue_id: 'venue123',
          client_id: 'client456',
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
        expect(client).to receive(:create_reservation).with(valid_params)
          .and_return({ status: 'success', reservation_id: '12345' })

        result = reservation.create(valid_params)
        expect(result).to eq({ status: 'success', reservation_id: '12345' })
      end

      it 'validates required parameters' do
        required_params = [:venue_id, :client_id, :arrival_time, :party_size]
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
    end

    context 'when API request fails' do
      let(:valid_params) do
        {
          venue_id: 'venue123',
          client_id: 'client456',
          arrival_time: '07:00:00 PM',
          party_size: 4
        }
      end

      it 'propagates API errors' do
        expect(client).to receive(:create_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.create(valid_params)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#update' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          arrival_time: '07:00:00 PM',
          party_size: 4,
          notes: 'Updated notes'
        }
      end

      it 'updates a reservation successfully' do
        expect(client).to receive(:update_reservation).with(
          reservation_id,
          valid_params
        ).and_return({ status: 'success' })

        result = reservation.update(reservation_id, valid_params)
        expect(result).to eq({ status: 'success' })
      end

      it 'validates party size is a positive integer' do
        invalid_params = valid_params.merge(party_size: -1)
        
        expect do
          reservation.update(reservation_id, invalid_params)
        end.to raise_error(ArgumentError, 'Party size must be a positive integer')
      end

      it 'validates time format' do
        invalid_params = valid_params.merge(arrival_time: 'invalid time')
        
        expect do
          reservation.update(reservation_id, invalid_params)
        end.to raise_error(ArgumentError, 'Time must be in format \'HH:MM:SS AM/PM\'')
      end

      it 'allows partial updates' do
        partial_params = { notes: 'New notes' }
        
        expect(client).to receive(:update_reservation).with(
          reservation_id,
          partial_params
        ).and_return({ status: 'success' })

        result = reservation.update(reservation_id, partial_params)
        expect(result).to eq({ status: 'success' })
      end

      it 'handles empty update parameters' do
        expect(client).to receive(:update_reservation).with(
          reservation_id,
          {}
        ).and_return({ status: 'success' })

        result = reservation.update(reservation_id, {})
        expect(result).to eq({ status: 'success' })
      end
    end

    context 'with invalid parameters' do
      it 'raises an error for non-integer party size' do
        invalid_params = { party_size: 'four' }
        
        expect do
          reservation.update(reservation_id, invalid_params)
        end.to raise_error(ArgumentError, 'Party size must be a positive integer')
      end

      it 'raises an error for invalid time format' do
        invalid_params = { arrival_time: '7 PM' }
        
        expect do
          reservation.update(reservation_id, invalid_params)
        end.to raise_error(ArgumentError, 'Time must be in format \'HH:MM:SS AM/PM\'')
      end
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:update_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.update(reservation_id, { notes: 'test' })
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#cancel' do
    context 'with valid parameters' do
      it 'cancels a reservation successfully' do
        expect(client).to receive(:cancel_reservation).with(
          reservation_id,
          {}
        ).and_return({ status: 'success' })

        result = reservation.cancel(reservation_id)
        expect(result).to eq({ status: 'success' })
      end

      it 'cancels with optional parameters' do
        params = { cancellation_reason: 'Guest request' }
        expect(client).to receive(:cancel_reservation).with(
          reservation_id,
          params
        ).and_return({ status: 'success' })

        result = reservation.cancel(reservation_id, params)
        expect(result).to eq({ status: 'success' })
      end
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:cancel_reservation).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.cancel(reservation_id)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#get' do
    context 'with valid reservation ID' do
      it 'retrieves a reservation successfully' do
        expected_response = {
          reservation_id: reservation_id,
          status: 'confirmed',
          party_size: 4,
          arrival_time: '07:00:00 PM'
        }

        expect(client).to receive(:get_reservation).with(reservation_id)
          .and_return(expected_response)

        result = reservation.get(reservation_id)
        expect(result).to eq(expected_response)
      end
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