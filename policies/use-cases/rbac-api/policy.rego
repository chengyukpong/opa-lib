package authz

import rego.v1

default allow := false

# Admin can do anything
allow if {
	"admin" in input.subject.roles
}

# Role-action matrix
allow if {
	some role in input.subject.roles
	some action in data.role_actions[role]
	action == input.action
	input.resource.tenant == input.subject.tenant
}

# Owner can manage their own resource
allow if {
	input.action in {"read", "update", "delete"}
	input.resource.owner_id == input.subject.user_id
	input.resource.tenant == input.subject.tenant
}
