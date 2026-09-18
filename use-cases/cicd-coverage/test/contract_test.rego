package cicd_coverage.contract_test

import rego.v1
import data.envelope

# Validate that package envelope exports all required SPI fields with correct types
test_spi_envelope_structure if {
	mock_input := {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}

	# Allowed must be boolean
	is_boolean(envelope.allowed) with input as mock_input

	# Code must be non-empty string
	is_string(envelope.code) with input as mock_input
	envelope.code != "" with input as mock_input

	# Reasons must be array or set
	valid_reasons with input as mock_input

	# Metadata must have policy_id and version
	is_object(envelope.metadata) with input as mock_input
	is_string(envelope.metadata.policy_id) with input as mock_input
	is_string(envelope.metadata.version) with input as mock_input
}

valid_reasons if {
	is_array(envelope.reasons)
}

valid_reasons if {
	is_set(envelope.reasons)
}
