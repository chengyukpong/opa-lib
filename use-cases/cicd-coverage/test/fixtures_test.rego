package ci_test

import rego.v1
import data.ci.pass
import data.common.decision.response
import data.common.schema

test_all_threshold_fixtures if {
	every _, c in data.test.threshold_cases {
		pass == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}

test_all_waiver_fixtures if {
	every _, c in data.test.waiver_cases {
		pass == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}

