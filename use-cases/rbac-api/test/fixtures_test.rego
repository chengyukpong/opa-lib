package authz_test

import rego.v1
import data.authz.allow

test_all_matrix_fixtures if {
	every _, c in data.test.matrix_cases {
		allow == c.expected with input as c.input
	}
}

test_all_ownership_tenant_fixtures if {
	every _, c in data.test.ownership_tenant_cases {
		allow == c.expected with input as c.input
	}
}
