require 'sevenrooms'
require 'json'
require 'date'

# Configure the gem with the provided credentials
Sevenrooms.configure do |config|
  config.client_id = '3716a4de80165423ca25964c9321f4f3742a6ec43482b8060f1be86f7d94e51c5e2db99d6435c4733eb102a7bc2e73df63b5d3cd5684e3e0a3fd4af383d47198'
  config.client_secret = '3fb0fd43ab186f9fe6518c0bb3c49e7315a4900766452baf7a5afac8e17943aee318cfc8d934f5630ada06ca141bdd9a3813fa9c24969b8e5f51acaf5350b8a0'
  config.concierge_id = 'ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yIAsSE25pZ2h0bG9vcF9Db25jaWVyZ2UYgICY_PuXqwoM'
  config.api_url = 'https://demo.sevenrooms.com/api-ext/2_4'
end

# Get the client instance
client = Sevenrooms.client

# Test creating a reservation
begin
  puts "\nTesting Create Reservation..."
  puts "API URL: #{client.api_url}"
  puts "Client ID: #{client.client_id}"
  puts "Concierge ID: #{client.concierge_id}"
  
  # Set up reservation parameters
  venue_id = "ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yHAsSD25pZ2h0bG9vcF9WZW51ZRiAgPDmntTGCww"
  params = {
    date: "2025-05-17",
    time: "17:00:00",
    party_size: 2,
    first_name: "Test",
    last_name: "User",
    email: "test@example.com",
    phone: "+12125551234",  # Updated to a valid US phone number in E.164 format
    notes: "Test reservation"
  }
  
  puts "\nAttempting to create reservation..."
  puts "Request parameters:"
  puts JSON.pretty_generate(params)
  
  result = client.create_reservation(venue_id, params)
  puts "\nAPI Response:"
  puts JSON.pretty_generate(result)
  
rescue Sevenrooms::APIError => e
  puts "\nAPI Error occurred:"
  puts "Error message: #{e.message}"
  puts "Error class: #{e.class}"
rescue Sevenrooms::ConfigurationError => e
  puts "\nConfiguration Error occurred:"
  puts "Error message: #{e.message}"
  puts "Error class: #{e.class}"
rescue StandardError => e
  puts "\nUnexpected error occurred:"
  puts "Error message: #{e.message}"
  puts "Error class: #{e.class}"
  puts "Backtrace:"
  puts e.backtrace
end 