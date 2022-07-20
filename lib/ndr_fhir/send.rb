module NdrFhir
  class Send
    attr_accessor :client, :patient, :other_fhir_models
    def initialize(client, fhir_models)
      @client = client
      @patient, @other_fhir_models = fhir_models.partition { |model| model.is_a? FHIR::Patient }
    end

    def call
      client.add_transaction_request('POST', nil, patient)
      other_fhir_models.each do |model|
        client.add_transaction_request('POST',nil, model)
      end
      client.end_transaction
    end
  end
end