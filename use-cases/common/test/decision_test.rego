package common.decision_test

import rego.v1
import data.common.decision.response
import data.common.contract
import data.common.schema

# Test standard envelope generation and JSON schema validation with mock envelope
test_decision_response_and_schema_validation if {
	mock_envelope := {
		"allowed": true,
		"code": "ALLOW_DEMO",
		"reasons": ["demonstration reason"],
		"metadata": {
			"policy_id": "demo-policy",
			"version": "1.0.0",
		},
	}

	# Verify SPI compliance helper
	contract.compliance_errors == set() with data.envelope as mock_envelope
	contract.is_compliant == true with data.envelope as mock_envelope

	# Verify Response generation
	res := response with data.envelope as mock_envelope
	res.allowed == true
	res.decision_code == "ALLOW_DEMO"
	res.reasons == ["demonstration reason"]
	res.metadata.policy_id == "demo-policy"

	# Verify JSON Schema
	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_decision_response_fallback_defaults if {
	# Verify fallback behavior when data.envelope is incomplete or missing
	res := response with data.envelope as {}
	res.allowed == false
	res.decision_code == "DENY_DEFAULT"
	res.reasons == []
	res.metadata.policy_id == "unknown-policy"

	# Schema must still be valid with default fallback
	schema_check := schema.validate_response(res)
	schema_check.valid == true
}
