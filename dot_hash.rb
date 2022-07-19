require 'fhir_models'

expected_hash = {
  'status' => 'final',
  'code' => {
    'coding' => [{ 'system' => 'http://loinc.org', 'code' => '3141-9', 'display' => 'Weight Measured' }],
    'text' => 'Weight Measured'
  },
  'category' => {
    'coding' => [{ 'system' => 'http://hl7.org/fhir/observation-category', 'code' => 'vital-signs' }]
  },
  'subject' => { 'reference' => 'Patient/example' },
  'context' => { 'reference' => 'Encounter/example' }
}

mapped_hash = {
  'status' => 'final',
  'code.coding[0].system' => 'http://loinc.org',
  'code.coding[0].code' => '3141-9',
  'code.coding[0].display' => 'Weight Measured',
  'code.text' => 'Weight Measured',
  'category.coding[0].system' => 'http://hl7.org/fhir/observation-category',
  'category.coding[0].code' => 'vital-signs',
  'subject.reference' => 'Patient/example',
  'context.reference' => 'Encounter/example',
  'valueQuantity.value' => 185,
  'valueQuantity.unit' => 'lbs',
  'valueQuantity.code' => '[lb_av]',
  'valueQuantity.system' => 'http://unitsofmeasure.org'
}

output_hash = {}
mapped_hash.each do |key, value|
  pointer = output_hash

  sections = key.split('.')
  sections[0..-2].each do |section|
    # not the last part
    matchdata = section.match(/\A([^\[]*)(?:\[(\d+)\]\z)?/)
    section = matchdata[1]

    if matchdata[2].nil?
      # hash
      pointer[section] ||= {}
      pointer = pointer[section]
    else
      # array
      array_index = matchdata[2].to_i
      pointer[section] ||= []
      pointer[section][array_index] ||= {}
      pointer = pointer[section][array_index]
    end
  end
  
  pointer[sections.last] = value
end

# puts expected_hash.inspect
puts output_hash.inspect
# raise 'Not the same' unless output_hash == expected_hash

obs = FHIR::Observation.new(output_hash)
puts obs.inspect
puts obs.validate.inspect

