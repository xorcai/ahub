require 'spec_helper'

module Ahub
  class APIResourceTester
    include Ahub::APIResource

    def self.create()
      url = "#{base_url}.json"

      create_resource(url: url, payload: {}.to_json, headers: admin_headers)
    end
  end
end

describe Ahub::APIResource do
  let(:server_response) do
    {page: 1, pageSize: 15, pageCount: 5, list: [single_response]}
  end

  let(:single_response){ {id: 8, title: 'foo'} }

  describe 'class methdods' do
    describe '::find' do
      it 'swallows RestClient::ResourceNotFound & returns nil if nothing comes back from the sever' do
        allow(RestClient).to receive(:get).with(
          "#{Ahub::APIResourceTester.base_url}/1.json",
          Ahub::APIResourceTester.admin_headers
        ).and_raise(RestClient::ResourceNotFound)

        tester = Ahub::APIResourceTester.find(1)
        expect(tester).to be_nil
      end

      it 'allows other exceptions to be raised' do
        allow(RestClient).to receive(:get).with(
          "#{Ahub::APIResourceTester.base_url}/k.json",
          Ahub::APIResourceTester.admin_headers
        ).and_raise(RestClient::InternalServerError)

        expect{ Ahub::APIResourceTester.find('k') }.to raise_error(RestClient::InternalServerError)
      end

      context 'when server has a useful response' do
        it 'makes a call to index route for all questions and returns an array of objects.' do
          allow(RestClient).to receive(:get).with(
            "#{Ahub::APIResourceTester.base_url}/8.json",
            Ahub::APIResourceTester.admin_headers
          ).and_return(single_response.to_json)

          expect(Ahub::APIResourceTester.find(8)).to be_a(Ahub::APIResourceTester)
        end
      end
    end

    describe '::find_all' do
      context 'when args are present' do
        it 'makes a call to index route with arguments' do
          allow(RestClient).to receive(:get).with(
            "#{Ahub::APIResourceTester.base_url}.json?page=1&pageSize=30&foo=bar%20quat",
            Ahub::APIResourceTester.admin_headers
          ).and_return(server_response.to_json)

          expect(Ahub::APIResourceTester.find_all(params: {foo:'bar quat'})).to all(be_a(Ahub::APIResourceTester))
        end
      end
    end

    describe '::base_url' do
      it 'returns a class derrived from the class' do
        expect(Ahub::APIResourceTester.base_url).to eq("#{Ahub::DOMAIN}/services/v2/apiresourcetester")
      end
    end

    describe '::object_id_from_response' do
      it 'returns an integer for the id of the new record' do
        base_url = Ahub::APIResourceTester.base_url
        response = double(headers: {location: "#{base_url}/123.json"})
        expect(Ahub::APIResourceTester.object_id_from_response(response)).to eq(123)
      end
    end

    describe '::create' do
      let(:create_url){ "#{Ahub::APIResourceTester.base_url}.json" }
      let(:server_response){ double(headers: {location: "#{Ahub::APIResourceTester.base_url}/456.json"}) }

      it 'returns an Ahub::APIResourceTester instance if creation was successful' do
        expect(RestClient).to receive(:post).with(
          create_url, anything, Ahub::APIResourceTester.admin_headers
        ).and_return(server_response)

        expect(Ahub::APIResourceTester).to receive(:find).and_return(Ahub::APIResourceTester.new({}))

        answer = Ahub::APIResourceTester.create()
        expect(answer).to be_a(Ahub::APIResourceTester)
      end

      it 'returns an error if a failure occurs' do
        allow(RestClient).to receive(:post).with(
          create_url, anything, Ahub::APIResourceTester.admin_headers
        ).and_raise(RestClient::InternalServerError)

        expect{Ahub::APIResourceTester.create()}.to raise_error(RestClient::InternalServerError)
      end
    end
  end

  describe 'instance methdods' do
    let(:tester){ Ahub::APIResourceTester.new({}) }
    describe '#initialize' do
      it 'requires new tests'
    end

    describe '#update' do
      it 'raises NotImplementedError' do
        expect{tester.update}.to raise_error(NotImplementedError)
      end
    end

    describe '#destroy' do
      it 'raises NotImplementedError' do
        expect{tester.update}.to raise_error(NotImplementedError)
      end
    end
  end
end