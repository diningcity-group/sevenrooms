require 'bundler/setup'
require 'webmock/rspec'
require 'sevenrooms'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset Sevenrooms configuration before each test
  config.before(:each) do
    Sevenrooms.api_key = nil
    Sevenrooms.api_url = nil
  end
end

# Configure WebMock to allow localhost connections
WebMock.disable_net_connect!(allow_localhost: true) 