package authz.test

import rego.v1
import data.authz.allow
import data.common.decision.response
import data.common.schema

test_admin_delete_allowed if {
	allow with input as {
		"subject": {"user_id": "u-admin", "roles": ["admin"], "tenant": "acme"},
		"action": "delete",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}

	res := response with input as {
		"subject": {"user_id": "u-admin", "roles": ["admin"], "tenant": "acme"},
		"action": "delete",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}
	res.allowed == true
	res.decision_code == "ALLOW_ADMIN_OVERRIDE"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_viewer_update_denied if {
	not allow with input as {
		"subject": {"user_id": "u-view", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}

	res := response with input as {
		"subject": {"user_id": "u-view", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}
	res.allowed == false
	res.decision_code == "DENY_INSUFFICIENT_ROLE"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_owner_update_allowed if {
	allow with input as {
		"subject": {"user_id": "u-1", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-1", "type": "invoice"},
	}

	res := response with input as {
		"subject": {"user_id": "u-1", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-1", "type": "invoice"},
	}
	res.allowed == true
	res.decision_code == "ALLOW_RESOURCE_OWNER"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}
