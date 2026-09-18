package authz.test

import rego.v1
import data.authz.allow
import data.authz.decision_code
import data.envelope

test_admin_delete_allowed if {
	mock_input := {
		"subject": {"user_id": "u-admin", "roles": ["admin"], "tenant": "acme"},
		"action": "delete",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}

	allow with input as mock_input
	decision_code == "ALLOW_ADMIN_OVERRIDE" with input as mock_input

	# Verify envelope export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_ADMIN_OVERRIDE" with input as mock_input
}

test_viewer_update_denied if {
	mock_input := {
		"subject": {"user_id": "u-view", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-other", "type": "invoice"},
	}

	not allow with input as mock_input
	decision_code == "DENY_INSUFFICIENT_ROLE" with input as mock_input

	# Verify envelope export
	envelope.allowed == false with input as mock_input
	envelope.code == "DENY_INSUFFICIENT_ROLE" with input as mock_input
}

test_owner_update_allowed if {
	mock_input := {
		"subject": {"user_id": "u-1", "roles": ["viewer"], "tenant": "acme"},
		"action": "update",
		"resource": {"tenant": "acme", "owner_id": "u-1", "type": "invoice"},
	}

	allow with input as mock_input
	decision_code == "ALLOW_RESOURCE_OWNER" with input as mock_input

	# Verify envelope export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_RESOURCE_OWNER" with input as mock_input
}
