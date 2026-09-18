package openshift.test

import rego.v1
import data.openshift.allowed
import data.envelope

test_all_basics_fixtures if {
	every _, c in data.openshift.test_fixtures.basics_cases {
		allowed == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}

test_all_exceptions_fixtures if {
	every _, c in data.openshift.test_fixtures.exceptions_cases {
		allowed == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}
