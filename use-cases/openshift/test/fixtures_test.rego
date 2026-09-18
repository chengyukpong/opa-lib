package openshift.test

import rego.v1
import data.openshift.allowed
import data.common.decision.response
import data.common.schema

test_all_basics_fixtures if {
	every _, c in data.test.basics_cases {
		allowed == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}

test_all_exceptions_fixtures if {
	every _, c in data.test.exceptions_cases {
		allowed == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}
