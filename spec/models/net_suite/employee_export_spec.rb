require 'rails_helper'

RSpec.describe NetSuite::EmployeeExport do
  let(:netsuite_client) { instance_double("NetSuite::Client") }
  let(:response) { double("Response", response: response_body, http_code: 400) }
  let(:exception) { NetSuite::ApiError.new(response) }

  subject(:exporter) do
    NetSuite::EmployeeExport.new(
      profile: profile,
      attributes: {},
      netsuite_client: netsuite_client
    )
  end

  describe '#create' do
    let(:profile) { double("Namely::Model", update: true, id: 'bunk') }

    before do
      allow(netsuite_client).to receive(:create_employee).and_raise(exception)
    end

    context 'when the request 400s because of a bad request' do
      let(:response_body) { { providerMessage: "Bad request: you goofed" }.to_json }

      it 'does not track the exception in raygun' do
        expect(Raygun).to_not receive(:track_exception)

        exporter.create
      end
    end

    context 'when the request 400s because of cloud elements' do
      let(:response_body) { { message: "java.lang.IllegalStateException: Session invalidation is in progress with different thread" }.to_json }

      it 'does not track the exception in raygun' do
        expect(Raygun).to receive(:track_exception)

        exporter.create
      end
    end
  end
end
