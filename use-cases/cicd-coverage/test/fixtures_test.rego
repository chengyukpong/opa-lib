package ci_test

import rego.v1
import data.ci.pass

test_all_threshold_fixtures if {
	every _, c in data.test.threshold_cases {
		pass == c.expected with input as c.input
	}
}

test_all_waiver_fixtures if {
	every _, c in data.test.waiver_cases {
		pass == c.expected with input as c.input
	}
}

