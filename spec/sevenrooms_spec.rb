require 'spec_helper'
require 'sevenrooms'

RSpec.describe Sevenrooms do
  describe '.configure' do
    it 'configures the API key and URL' do
      Sevenrooms.configure do |config|
        config.api_key = 'test_key'
        config.api_url = 'https://api.sevenrooms.com/2_4'
      end

      expect(Sevenrooms.api_key).to eq('test_key')
      expect(Sevenrooms.api_url).to eq('https://api.sevenrooms.com/2_4')
    end
  end

  describe '.client' do
    before do
      Sevenrooms.configure do |config|
        config.api_key = 'test_key'
        config.api_url = 'https://api.sevenrooms.com/2_4'
      end
    end

    it 'returns a client instance' do
      expect(Sevenrooms.client).to be_a(Sevenrooms::Client)
    end

    it 'memoizes the client instance' do
      first_client = Sevenrooms.client
      second_client = Sevenrooms.client
      expect(first_client).to equal(second_client)
    end

    it 'configures the client with the correct API key and URL' do
      client = Sevenrooms.client
      expect(client.api_key).to eq('test_key')
      expect(client.api_url).to eq('https://api.sevenrooms.com/2_4')
    end
  end

  describe 'Error classes' do
    it 'defines Error class' do
      expect(Sevenrooms::Error).to be < StandardError
    end

    it 'defines ConfigurationError class' do
      expect(Sevenrooms::ConfigurationError).to be < Sevenrooms::Error
    end

    it 'defines APIError class' do
      expect(Sevenrooms::APIError).to be < Sevenrooms::Error
    end
  end
end 