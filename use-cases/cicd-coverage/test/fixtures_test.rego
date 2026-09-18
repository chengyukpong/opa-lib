package cicd_coverage.test

import rego.v1
import data.cicd_coverage.pass
import data.envelope

test_all_threshold_fixtures if {
	every _, c in data.cicd_coverage.test_fixtures.threshold_cases {
		pass == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}

test_all_waiver_fixtures if {
	every _, c in data.cicd_coverage.test_fixtures.waiver_cases {
		pass == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}

