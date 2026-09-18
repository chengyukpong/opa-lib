package authz.test

import rego.v1
import data.authz.allow
import data.envelope

test_all_matrix_fixtures if {
	every _, c in data.authz.test_fixtures.matrix_cases {
		allow == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}

test_all_ownership_tenant_fixtures if {
	every _, c in data.authz.test_fixtures.ownership_tenant_cases {
		allow == c.expected with input as c.input
		envelope.allowed == c.expected with input as c.input
	}
}
