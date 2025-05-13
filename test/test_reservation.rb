require 'test_helper'
require 'sevenrooms/reservation'

class TestReservation < Minitest::Test
  include TestHelpers

  def setup
    @client = MockClient.new
    @reservation = Sevenrooms::Reservation.new(@client)
  end

  def test_create_reservation_success
    response = mock_successful_response
    @client.expect(:create_reservation, response)
    
    result = @reservation.create(valid_reservation_params)
    
    assert_equal 'confirmed', result.status
    assert_equal 'test_123', result.id
    assert_equal 4, result.party_size
  end

  def test_create_reservation_with_invalid_phone
    params = valid_reservation_params.merge(phone: 'invalid')
    
    assert_raises(ArgumentError) do
      @reservation.create(params)
    end
  end

  def test_create_reservation_without_required_params
    params = valid_reservation_params.reject { |k, _| k == :phone }
    response = mock_error_response
    @client.expect(:create_reservation, response)
    
    assert_raises(Sevenrooms::APIError) do
      @reservation.create(params)
    end
  end

  def test_update_reservation_success
    response = MockResponse.new(
      status: 'confirmed',
      body: {
        'id' => 'test_123',
        'max_guests' => 6,
        'arrival_time' => '07:00:00 PM'
      }
    )
    @client.expect(:update_reservation, response)

    result = @reservation.update({ party_size: 6 })

    assert_equal 'confirmed', result.status
    assert_equal 6, result.party_size
  end

  def test_cancel_reservation_success
    response = mock_successful_response
    @client.expect(:cancel_reservation, response)
    
    result = @reservation.cancel('Customer request')
    
    assert_equal 'confirmed', result.status
  end

  def test_get_reservation_success
    response = mock_successful_response
    @client.expect(:get_reservation, response)
    
    result = @reservation.get('test_123')
    
    assert_equal 'confirmed', result.status
    assert_equal '07:00:00 PM', result.arrival_time
    assert_equal 4, result.party_size
  end

  def test_handle_api_error
    response = mock_error_response
    @client.expect(:create_reservation, response)
    
    assert_raises(Sevenrooms::APIError) do
      @reservation.create(valid_reservation_params)
    end
  end

  def test_phone_number_formatting
    params = valid_reservation_params.merge(phone: '+852 6446 5065')
    response = mock_successful_response
    @client.expect(:create_reservation, response)
    
    result = @reservation.create(params)
    
    assert_equal 'confirmed', result.status
  end
end 