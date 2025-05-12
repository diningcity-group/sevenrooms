# Sevenrooms

A Ruby gem for interacting with the SevenRooms API v2.4. This gem provides a simple and intuitive interface for managing reservations in SevenRooms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Basic Setup](#basic-setup)
  - [Managing Reservations](#managing-reservations)
  - [Batch Operations](#batch-operations)
  - [Error Handling](#error-handling)
- [Migration Guide](#migration-guide)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Prerequisites

- Ruby 3.1.0 or higher
- A valid SevenRooms API client ID and secret
- A valid SevenRooms Concierge ID
- Access to the SevenRooms API endpoints

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sevenrooms'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install sevenrooms
```

## Configuration

The gem requires the following configuration parameters:

```ruby
client = Sevenrooms::Client.new(
  client_id: 'your_client_id',
  client_secret: 'your_client_secret',
  concierge_id: 'your_concierge_id',
  # Optional configuration
  api_url: 'https://api.sevenrooms.com/2_4'  # API base URL (default: demo URL)
)
```

## Dependencies

The gem has the following runtime dependencies:
- faraday (~> 2.0) - For HTTP requests
- json (~> 2.6) - For JSON parsing
- openssl (~> 3.0) - For secure connections

## Usage

### Basic Setup

```ruby
require 'sevenrooms'

# Initialize the client with your credentials
client = Sevenrooms::Client.new(
  client_id: 'your_client_id',
  client_secret: 'your_client_secret',
  concierge_id: 'your_concierge_id'
)

# Create a reservation manager
reservation = Sevenrooms::Reservation.new(client)
```

### Managing Reservations

#### Create a Reservation

```ruby
# Method 1: Using arrival_time (includes both date and time)
params = {
  venue_id: 'venue123',
  arrival_time: '2024-04-01 07:00:00 PM',  # Format: YYYY-MM-DD HH:MM:SS AM/PM
  party_size: 4
}

# Method 2: Using reservation_time (will be split into date and time)
params = {
  venue_id: 'venue123',
  reservation_time: '2024-04-01 07:00:00 PM',  # Format: YYYY-MM-DD HH:MM:SS AM/PM
  party_size: 4
}

# Optional parameters
optional_params = {
  first_name: 'John',
  last_name: 'Doe',
  email: 'john@example.com',
  phone: '123-456-7890',
  notes: 'Window seat preferred',
  external_id: 'your_external_id',
  prepayment: true,
  prepayment_total: 50.00
}

# Create the reservation
result = reservation.create(params.merge(optional_params))
```

#### Update a Reservation

```ruby
# Update specific fields
reservation.update(
  arrival_time: '08:00:00 PM',
  party_size: 6,
  notes: 'Updated to larger party'
)

# Partial updates are supported
reservation.update(notes: 'Updated notes only')
```

#### Cancel a Reservation

```ruby
# Cancel with reason
reservation.cancel('Guest request')

# Cancel without reason
reservation.cancel
```

#### Get a Reservation

```ruby
# Get reservation details
details = reservation.get('reservation_id')
puts "Reservation status: #{details.status}"
puts "Party size: #{details.party_size}"
```

#### List Reservations

```ruby
# Basic listing with filters
reservations = reservation.list(
  venue_id: 'venue123',
  from_date: '2024-04-01',
  to_date: '2024-04-30',
  status: 'confirmed',
  limit: 50,
  page: 1
)

# Process all reservations with automatic pagination
reservation.list_all(venue_id: 'venue123') do |page|
  page[:results].each do |res|
    puts "Found reservation: #{res[:id]}"
    puts "Status: #{res[:status]}"
    puts "Party size: #{res[:party_size]}"
  end
end
```

### Batch Operations

#### Create Multiple Reservations

```ruby
reservations = [
  {
    venue_id: 'venue123',
    arrival_time: '07:00:00 PM',
    party_size: 4
  },
  {
    venue_id: 'venue123',
    arrival_time: '08:00:00 PM',
    party_size: 2
  }
]

results = reservation.create_batch(reservations)
results.each do |result|
  if result.is_a?(Sevenrooms::APIError)
    puts "Failed to create reservation: #{result.message}"
  else
    puts "Created reservation: #{result[:reservation_id]}"
  end
end
```

#### Update Multiple Reservations

```ruby
updates = [
  { 
    reservation_id: '12345',
    params: { notes: 'Updated note 1' }
  },
  {
    reservation_id: '67890',
    params: { notes: 'Updated note 2' }
  }
]

results = reservation.update_batch(updates)
```

#### Cancel Multiple Reservations

```ruby
cancellations = [
  {
    reservation_id: '12345',
    params: { cancellation_reason: 'Guest request' }
  },
  {
    reservation_id: '67890',
    params: { cancellation_reason: 'Venue request' }
  }
]

results = reservation.cancel_batch(cancellations)
```

#### Get Multiple Reservations

```ruby
results = reservation.get_batch(['12345', '67890'])
```

### Error Handling

The gem provides comprehensive validation and error handling:

```ruby
begin
  reservation.create(params)
rescue Sevenrooms::APIError => e
  # Handle API errors (network issues, invalid responses, etc.)
  puts "API Error: #{e.message}"
rescue ArgumentError => e
  # Handle validation errors
  case e.message
  when /Missing required parameters/
    puts "Missing required fields: #{e.message}"
  when /Party size must be a positive integer/
    puts "Invalid party size"
  when /Time must be in format/
    puts "Invalid time format"
  when /Invalid phone number format/
    puts "Invalid phone number"
  when /Invalid email format/
    puts "Invalid email address"
  else
    puts "Validation error: #{e.message}"
  end
rescue => e
  # Handle any other errors
  puts "Unexpected error: #{e.message}"
end
```

## Migration Guide

The `Booking` class is deprecated and will be removed in the next major version. Please use the `Reservation` class instead.

### Key Changes

1. Class Name:
   - Old: `Booking`
   - New: `Reservation`

2. Parameter Changes:
   - Old: Separate `date` and `time` parameters
   - New: Combined `arrival_time` parameter (format: "HH:MM:SS AM/PM")

3. New Features:
   - Batch operations
   - Pagination support
   - Enhanced validation
   - Better error handling
   - Standardized responses

### Example Migration

```ruby
# Old code
booking = Sevenrooms::Booking.new(client)
booking.create(
  venue_id: "123",
  date: "2024-04-01",
  time: "7:00 PM",
  party_size: 4
)

# New code
reservation = Sevenrooms::Reservation.new(client)
reservation.create(
  venue_id: "123",
  arrival_time: "07:00:00 PM",
  party_size: 4
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/sevenrooms/reservation_spec.rb

# Run with coverage
bundle exec rspec --format documentation --color
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smartcoder0215/sevenrooms. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/smartcoder0215/sevenrooms/blob/main/CODE_OF_CONDUCT.md).

### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sevenrooms project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smartcoder0215/sevenrooms/blob/main/CODE_OF_CONDUCT.md).
