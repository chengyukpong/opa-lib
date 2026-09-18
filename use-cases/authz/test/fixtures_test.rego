package authz.test

import rego.v1
import data.authz.allow
import data.common.decision.response
import data.common.schema

test_all_matrix_fixtures if {
	every _, c in data.test.matrix_cases {
		allow == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}

test_all_ownership_tenant_fixtures if {
	every _, c in data.test.ownership_tenant_cases {
		allow == c.expected with input as c.input
		res := response with input as c.input
		res.allowed == c.expected

		schema_check := schema.validate_response(res)
		schema_check.valid == true
	}
}
