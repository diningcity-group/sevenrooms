# frozen_string_literal: true

require 'sevenrooms'

# Configure the gem
Sevenrooms.configure do |config|
  config.client_id = '3716a4de80165423ca25964c9321f4f3742a6ec43482b8060f1be86f7d94e51c5e2db99d6435c4733eb102a7bc2e73df63b5d3cd5684e3e0a3fd4af383d47198'
  config.client_secret = '3fb0fd43ab186f9fe6518c0bb3c49e7315a4900766452baf7a5afac8e17943aee318cf8d934f5630ada06ca141bdd9a3813fa9c24969b8e5f51acaf5350b8a0'
  config.concierge_id = 'ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yIAsSE25pZ2h0bG9vcF9Db25jaWVyZ2UYgICY_PuXqwoM'
  config.api_url = "https://demo.sevenrooms.com/api-ext/2_4"
end

# Get the client instance
client = Sevenrooms.client

# Example: Create a reservation
begin
  params = {
    venue_id: "ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yHAsSD25pZ2h0bG9vcF9WZW51ZRiAgPDmntTGCww",
    reservation_time: "2025-05-14 12:00:00 PM",
    party_size: 2,
    first_name: "Vartan",
    last_name: "Mundigian",
    email: "vatche.mundigian@traditionasia.com",
    phone: "85264465065",
    external_id: "4RU86XFG2W",
    prepayment: false,
    prepayment_total: 0,
    bypass_availability: true,
    bypass_required_contact_fields: true,
    bypass_duplicate_reservation_check: true,
    bypass_editable_cutoff: true
  }

  # Create the reservation
  result = client.create_reservation(params[:venue_id], params)
  puts "Reservation created successfully!"
  puts "Reservation details: #{result.inspect}"

rescue Sevenrooms::APIError => e
  puts "API Error: #{e.message}"
rescue Sevenrooms::ConfigurationError => e
  puts "Configuration Error: #{e.message}"
rescue StandardError => e
  puts "Error: #{e.message}"
end 