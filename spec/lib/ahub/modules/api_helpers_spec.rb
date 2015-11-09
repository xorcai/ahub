require 'spec_helper'

module Ahub
  class APIHelpersTester
    extend Ahub::APIHelpers
    def initialize(params)
    end
  end
end

describe Ahub::APIHelpers do
  describe '::find' do
    it 'swallows RestClient::ResourceNotFound & returns nil if nothing comes back from the sever' do
      allow(RestClient).to receive(:get).with(
        "#{Ahub::APIHelpersTester.base_url}/1.json",
        Ahub::APIHelpersTester.admin_headers
      ).and_raise(RestClient::ResourceNotFound)

      tester = Ahub::APIHelpersTester.find(1)
      expect(tester).to be_nil
    end

    it 'allows other exceptions to be raised' do
      allow(RestClient).to receive(:get).with(
        "#{Ahub::APIHelpersTester.base_url}/k.json",
        Ahub::APIHelpersTester.admin_headers
      ).and_raise(RestClient::InternalServerError)

      expect{ Ahub::APIHelpersTester.find('k') }.to raise_error(RestClient::InternalServerError)
    end

    context 'when server has a useful response' do
      let(:server_response) do
        {page: 1, pageSize: 15, pageCount: 5, list: [single_response]}.to_json
      end

      let(:single_response){ {id: 8, title: 'foo'} }

      before do
        allow(RestClient).to receive(:get).with(
          "#{Ahub::APIHelpersTester.base_url}/8.json",
          Ahub::APIHelpersTester.admin_headers
        ).and_return(single_response.to_json)
      end

      it 'makes a call to index route for all questions and returns an array of objects.' do
        expect(Ahub::APIHelpersTester.find(8)).to be_a(Ahub::APIHelpersTester)
      end
    end
  end

  describe '::find_all' do
    context 'when args are present' do
      xit 'makes a call to index route with arguments'
    end
  end

  describe '::base_url' do
    #for simplicity, I'm simply sending this private method call.
    it 'returns a class derrived from the class' do
      expect(Ahub::APIHelpersTester.send(:base_url)).to eq("#{Ahub::DOMAIN}/services/v2/apihelperstester")
    end
  end
end
