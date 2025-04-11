require 'spec_helper'
require 'sevenrooms'

RSpec.describe Sevenrooms do
  let(:client_id) { '3716a4de80165423ca25964c9321f4f3742a6ec43482b8060f1be86f7d94e51c5e2db99d6435c4733eb102a7bc2e73df63b5d3cd5684e3e0a3fd4af383d47198' }
  let(:client_secret) { '3fb0fd43ab186f9fe6518c0bb3c49e7315a4900766452baf7a5afac8e17943aee318cf8d934f5630ada06ca141bdd9a3813fa9c24969b8e5f51acaf5350b8a0' }
  let(:concierge_id) { 'ahhzfnNldmVucm9vbXMtc2VjdXJlLWRlbW9yIAsSE25pZ2h0bG9vcF9Db25jaWVyZ2UYgICY_PuXqwoM' }
  let(:api_url) { 'https://demo.sevenrooms.com/api-ext/2_4/' }

  describe '.configure' do
    it 'configures the credentials and URL' do
      Sevenrooms.configure do |config|
        config.client_id = client_id
        config.client_secret = client_secret
        config.concierge_id = concierge_id
        config.api_url = api_url
      end

      expect(Sevenrooms.client_id).to eq(client_id)
      expect(Sevenrooms.client_secret).to eq(client_secret)
      expect(Sevenrooms.concierge_id).to eq(concierge_id)
      expect(Sevenrooms.api_url).to eq(api_url)
    end
  end

  describe '.client' do
    before do
      Sevenrooms.configure do |config|
        config.client_id = client_id
        config.client_secret = client_secret
        config.concierge_id = concierge_id
        config.api_url = api_url
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

    it 'configures the client with the correct credentials' do
      client = Sevenrooms.client
      expect(client.client_id).to eq(client_id)
      expect(client.client_secret).to eq(client_secret)
      expect(client.concierge_id).to eq(concierge_id)
      expect(client.api_url).to eq(api_url)
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