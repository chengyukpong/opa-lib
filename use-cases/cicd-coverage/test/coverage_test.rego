package ci_test

import rego.v1
import data.ci.pass

test_ts_pass if {
	pass with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}
}

test_ts_fail if {
	not pass with input as {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 9
	}
}

test_valid_waiver if {
	pass with input as {
		"repo": "acme/legacy-portal",
		"language": "typescript",
		"coverage_pct": 40,
	}
}
