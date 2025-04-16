require 'test_helper'
require 'sevenrooms/reservation'

class TestReservation < Minitest::Test
  def setup
    @client = Sevenrooms::Client.new(
      client_id: 'test_client_id',
      client_secret: 'test_client_secret',
      concierge_id: 'test_concierge_id'
    )
    @reservation = Sevenrooms::Reservation.new(@client)
  end

  def test_create_reservation
    params = {
      venue_id: '123',
      arrival_time: '07:00:00 PM',
      party_size: 4,
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com',
      phone: '123-456-7890'
    }
    response = @reservation.create(params)
    assert_equal 'confirmed', response.status
  end

  def test_update_reservation
    params = {
      first_name: 'Jane',
      last_name: 'Doe'
    }
    response = @reservation.update(params)
    assert_equal 'confirmed', response.status
  end

  def test_cancel_reservation
    response = @reservation.cancel('Customer request')
    assert_equal 'cancelled', response.status
  end

  def test_get_reservation
    response = @reservation.get('123')
    assert_equal 'confirmed', response.status
    assert_equal '07:00:00 PM', response.arrival_time
    assert_equal 4, response.party_size
  end
end 