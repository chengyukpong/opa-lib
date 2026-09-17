package ci_test

import rego.v1
import data.ci.pass
import data.common.decision.response
import data.common.schema

test_ts_pass if {
	pass with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}

	res := response with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}
	res.allowed == true
	res.decision_code == "ALLOW_THRESHOLD_MET"

	# Validate against corporate response JSON schema
	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_ts_fail if {
	not pass with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 9,
	}

	res := response with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 9,
	}
	res.allowed == false
	res.decision_code == "DENY_COVERAGE_BELOW_THRESHOLD"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_valid_waiver if {
	pass with input as {
		"repo": "acme/legacy-portal",
		"language": "typescript",
		"coverage_pct": 40,
	}

	res := response with input as {
		"repo": "acme/legacy-portal",
		"language": "typescript",
		"coverage_pct": 40,
	}
	res.allowed == true
	res.decision_code == "ALLOW_WAIVER"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}
