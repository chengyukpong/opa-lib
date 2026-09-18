package cicd_coverage.test

import rego.v1
import data.cicd_coverage.pass
import data.cicd_coverage.decision_code
import data.envelope

test_ts_pass if {
	mock_input := {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}

	pass with input as mock_input
	decision_code == "ALLOW_THRESHOLD_MET" with input as mock_input

	# Verify envelope adapter export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_THRESHOLD_MET" with input as mock_input
}

test_ts_fail if {
	mock_input := {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 9,
	}

	not pass with input as mock_input
	decision_code == "DENY_COVERAGE_BELOW_THRESHOLD" with input as mock_input

	# Verify envelope adapter export
	envelope.allowed == false with input as mock_input
	envelope.code == "DENY_COVERAGE_BELOW_THRESHOLD" with input as mock_input
}

test_valid_waiver if {
	mock_input := {
		"repo": "acme/legacy-portal",
		"language": "typescript",
		"coverage_pct": 40,
	}

	pass with input as mock_input
	decision_code == "ALLOW_WAIVER" with input as mock_input

	# Verify envelope adapter export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_WAIVER" with input as mock_input
}
