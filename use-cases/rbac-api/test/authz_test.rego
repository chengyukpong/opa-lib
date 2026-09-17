package authz_test

import rego.v1
import data.authz.allow

test_admin_delete_allowed if {
	allow with input as {
		"subject": {"user_id": "u-admin", "roles": ["admin"], "tenant": "acme"},
		"action": "delete",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}
}

test_viewer_update_denied if {
	not allow with input as {
		"subject": {"user_id": "u-view", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}
}

test_owner_update_allowed if {
	allow with input as {
		"subject": {"user_id": "u-1", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-1", "type": "invoice"},
	}
}
