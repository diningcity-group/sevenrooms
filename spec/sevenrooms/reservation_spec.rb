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

  describe '#create_batch' do
    let(:reservations) do
      [
        {
          venue_id: 'venue123',
          client_id: 'client456',
          arrival_time: '07:00:00 PM',
          party_size: 4
        },
        {
          venue_id: 'venue123',
          client_id: 'client789',
          arrival_time: '08:00:00 PM',
          party_size: 2
        }
      ]
    end

    it 'creates multiple reservations' do
      reservations.each do |params|
        expect(client).to receive(:create_reservation).with(params)
          .and_return({ status: 'success', reservation_id: SecureRandom.hex(4) })
      end

      results = reservation.create_batch(reservations)
      expect(results.size).to eq(2)
      expect(results.all? { |r| r[:status] == 'success' }).to be true
    end

    it 'handles API errors for individual reservations' do
      expect(client).to receive(:create_reservation).with(reservations[0])
        .and_return({ status: 'success', reservation_id: '12345' })
      expect(client).to receive(:create_reservation).with(reservations[1])
        .and_raise(Sevenrooms::APIError, 'API Error')

      results = reservation.create_batch(reservations)
      expect(results.size).to eq(2)
      expect(results[0][:status]).to eq('success')
      expect(results[1]).to be_a(Sevenrooms::APIError)
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

  describe '#update_batch' do
    let(:updates) do
      [
        { reservation_id: '12345', params: { notes: 'Updated note 1' } },
        { reservation_id: '67890', params: { notes: 'Updated note 2' } }
      ]
    end

    it 'updates multiple reservations' do
      updates.each do |update|
        expect(client).to receive(:update_reservation).with(
          update[:reservation_id],
          update[:params]
        ).and_return({ status: 'success' })
      end

      results = reservation.update_batch(updates)
      expect(results.size).to eq(2)
      expect(results.all? { |r| r[:status] == 'success' }).to be true
    end

    it 'handles API errors for individual updates' do
      expect(client).to receive(:update_reservation).with(updates[0][:reservation_id], updates[0][:params])
        .and_return({ status: 'success' })
      expect(client).to receive(:update_reservation).with(updates[1][:reservation_id], updates[1][:params])
        .and_raise(Sevenrooms::APIError, 'API Error')

      results = reservation.update_batch(updates)
      expect(results.size).to eq(2)
      expect(results[0][:status]).to eq('success')
      expect(results[1]).to be_a(Sevenrooms::APIError)
    end
  end

  describe '#cancel' do
    context 'with valid parameters' do
      it 'cancels a reservation successfully' do
        expect(client).to receive(:cancel_reservation).with(
          reservation_id,
          { cancellation_reason: 'Guest request' }
        ).and_return({ status: 'success' })

        result = reservation.cancel(reservation_id, { cancellation_reason: 'Guest request' })
        expect(result).to eq({ status: 'success' })
      end

      it 'allows cancellation without reason' do
        expect(client).to receive(:cancel_reservation).with(
          reservation_id,
          {}
        ).and_return({ status: 'success' })

        result = reservation.cancel(reservation_id)
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

  describe '#cancel_batch' do
    let(:cancellations) do
      [
        { reservation_id: '12345', params: { cancellation_reason: 'Reason 1' } },
        { reservation_id: '67890', params: { cancellation_reason: 'Reason 2' } }
      ]
    end

    it 'cancels multiple reservations' do
      cancellations.each do |cancellation|
        expect(client).to receive(:cancel_reservation).with(
          cancellation[:reservation_id],
          cancellation[:params]
        ).and_return({ status: 'success' })
      end

      results = reservation.cancel_batch(cancellations)
      expect(results.size).to eq(2)
      expect(results.all? { |r| r[:status] == 'success' }).to be true
    end

    it 'handles API errors for individual cancellations' do
      expect(client).to receive(:cancel_reservation).with(cancellations[0][:reservation_id], cancellations[0][:params])
        .and_return({ status: 'success' })
      expect(client).to receive(:cancel_reservation).with(cancellations[1][:reservation_id], cancellations[1][:params])
        .and_raise(Sevenrooms::APIError, 'API Error')

      results = reservation.cancel_batch(cancellations)
      expect(results.size).to eq(2)
      expect(results[0][:status]).to eq('success')
      expect(results[1]).to be_a(Sevenrooms::APIError)
    end
  end

  describe '#get' do
    it 'retrieves a reservation successfully' do
      reservation_data = {
        id: reservation_id,
        status: 'confirmed',
        arrival_time: '07:00:00 PM'
      }

      expect(client).to receive(:get_reservation).with(
        reservation_id
      ).and_return(reservation_data)

      result = reservation.get(reservation_id)
      expect(result).to eq(reservation_data)
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

  describe '#get_batch' do
    let(:reservation_ids) { ['12345', '67890'] }

    it 'retrieves multiple reservations' do
      reservation_ids.each do |id|
        expect(client).to receive(:get_reservation).with(id)
          .and_return({ id: id, status: 'confirmed' })
      end

      results = reservation.get_batch(reservation_ids)
      expect(results.size).to eq(2)
      expect(results.map { |r| r[:id] }).to eq(reservation_ids)
    end

    it 'handles API errors for individual retrievals' do
      expect(client).to receive(:get_reservation).with(reservation_ids[0])
        .and_return({ id: reservation_ids[0], status: 'confirmed' })
      expect(client).to receive(:get_reservation).with(reservation_ids[1])
        .and_raise(Sevenrooms::APIError, 'API Error')

      results = reservation.get_batch(reservation_ids)
      expect(results.size).to eq(2)
      expect(results[0][:id]).to eq(reservation_ids[0])
      expect(results[1]).to be_a(Sevenrooms::APIError)
    end
  end

  describe '#list' do
    let(:list_params) do
      {
        venue_id: 'venue123',
        from_date: '2024-04-01',
        to_date: '2024-04-30',
        status: 'confirmed',
        limit: 50,
        page: 1
      }
    end

    it 'lists reservations successfully' do
      response_data = {
        results: [
          { id: '123', status: 'confirmed' },
          { id: '456', status: 'confirmed' }
        ],
        total: 2,
        has_more: false
      }

      expect(client).to receive(:list_reservations).with(
        list_params
      ).and_return(response_data)

      result = reservation.list(list_params)
      expect(result).to eq(response_data)
    end

    it 'validates limit parameter' do
      invalid_params = list_params.merge(limit: 0)
      
      expect do
        reservation.list(invalid_params)
      end.to raise_error(ArgumentError, 'Limit must be between 1 and 400')
    end

    it 'validates page parameter' do
      invalid_params = list_params.merge(page: 0)
      
      expect do
        reservation.list(invalid_params)
      end.to raise_error(ArgumentError, 'Page must be a positive integer')
    end

    it 'validates date format' do
      invalid_params = list_params.merge(from_date: '2024/04/01')
      
      expect do
        reservation.list(invalid_params)
      end.to raise_error(ArgumentError, 'from_date must be in format YYYY-MM-DD')
    end

    it 'allows listing without parameters' do
      response_data = { results: [], total: 0, has_more: false }

      expect(client).to receive(:list_reservations).with(
        {}
      ).and_return(response_data)

      result = reservation.list
      expect(result).to eq(response_data)
    end

    context 'when API request fails' do
      it 'propagates API errors' do
        expect(client).to receive(:list_reservations).and_raise(Sevenrooms::APIError, 'API Error')
        
        expect do
          reservation.list(list_params)
        end.to raise_error(Sevenrooms::APIError, 'API Error')
      end
    end
  end

  describe '#list_all' do
    let(:list_params) do
      {
        venue_id: 'venue123',
        from_date: '2024-04-01',
        to_date: '2024-04-30',
        status: 'confirmed',
        limit: 50
      }
    end

    it 'processes all pages of results' do
      responses = [
        {
          results: [{ id: '1' }, { id: '2' }],
          has_more: true
        },
        {
          results: [{ id: '3' }, { id: '4' }],
          has_more: true
        },
        {
          results: [{ id: '5' }],
          has_more: false
        }
      ]

      responses.each_with_index do |response, index|
        expect(client).to receive(:list_reservations)
          .with(list_params.merge(page: index + 1))
          .and_return(response)
      end

      results = []
      reservation.list_all(list_params) do |response|
        results.concat(response[:results])
      end

      expect(results.size).to eq(5)
      expect(results.map { |r| r[:id] }).to eq(['1', '2', '3', '4', '5'])
    end

    it 'handles empty results' do
      response = { results: [], has_more: false }
      expect(client).to receive(:list_reservations)
        .with(list_params.merge(page: 1))
        .and_return(response)

      results = []
      reservation.list_all(list_params) do |response|
        results.concat(response[:results])
      end

      expect(results).to be_empty
    end

    it 'handles API errors' do
      expect(client).to receive(:list_reservations)
        .with(list_params.merge(page: 1))
        .and_raise(Sevenrooms::APIError, 'API Error')

      expect do
        reservation.list_all(list_params) {}
      end.to raise_error(Sevenrooms::APIError, 'API Error')
    end
  end
end 