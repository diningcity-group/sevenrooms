require 'minitest/autorun'
require 'minitest/mock'
require 'sevenrooms'

# Mock response class to simulate API responses
class MockResponse
  attr_reader :status, :body

  def initialize(status: 'confirmed', body: {})
    @status = status
    @body = body
  end

  def to_h
    {
      'data' => {
        'status' => @status,
        'id' => 'test_123',
        'max_guests' => 4,
        'arrival_time' => '07:00:00 PM',
        'notes' => 'Test reservation'
      }.merge(@body)
    }
  end

  def [](key)
    to_h[key]
  end

  def method_missing(method_name, *args, &block)
    data = to_h['data']
    str_key = method_name.to_s
    sym_key = method_name.to_sym
    return data[str_key] if data.key?(str_key)
    return data[sym_key] if data.key?(sym_key)
    super
  end
end

# Mock client class to simulate SevenRooms client
class MockClient
  def initialize
    @responses = {}
  end

  def is_a?(klass)
    klass == Sevenrooms::Client
  end

  def create_reservation(venue_id, params)
    response = @responses[:create_reservation]
    raise Sevenrooms::APIError, "No mock response set for create_reservation" unless response
    raise Sevenrooms::APIError, response.body['msg'] if response.status == 'error'
    response
  end

  def update_reservation(reservation_id, params)
    response = @responses[:update_reservation]
    raise Sevenrooms::APIError, "No mock response set for update_reservation" unless response
    raise Sevenrooms::APIError, response.body['msg'] if response.status == 'error'
    response
  end

  def cancel_reservation(reservation_id, params = {})
    response = @responses[:cancel_reservation]
    raise Sevenrooms::APIError, "No mock response set for cancel_reservation" unless response
    raise Sevenrooms::APIError, response.body['msg'] if response.status == 'error'
    response
  end

  def get_reservation(reservation_id)
    response = @responses[:get_reservation]
    raise Sevenrooms::APIError, "No mock response set for get_reservation" unless response
    raise Sevenrooms::APIError, response.body['msg'] if response.status == 'error'
    response
  end

  def expect(method, response)
    @responses[method] = response
  end
end

# Helper methods for tests
module TestHelpers
  def mock_successful_response
    MockResponse.new(
      status: 'confirmed',
      body: {
        'id' => 'test_123',
        'max_guests' => 4,
        'arrival_time' => '07:00:00 PM'
      }
    )
  end

  def mock_error_response
    MockResponse.new(
      status: 'error',
      body: {
        'msg' => 'Invalid parameters'
      }
    )
  end

  def valid_reservation_params
    {
      venue_id: 'test_venue',
      arrival_time: '07:00:00 PM',
      party_size: 4,
      phone: '+852 6446 5065',
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com'
    }
  end
end 