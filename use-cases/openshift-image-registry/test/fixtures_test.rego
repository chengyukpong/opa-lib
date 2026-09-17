package image_policy_test

import rego.v1
import data.image_policy.allowed

test_all_basics_fixtures if {
	every _, c in data.test.basics_cases {
		allowed == c.expected with input as c.input
	}
}

test_all_exceptions_fixtures if {
	every _, c in data.test.exceptions_cases {
		allowed == c.expected with input as c.input
	}
}
