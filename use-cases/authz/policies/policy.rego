package authz

import rego.v1

default allow := false
default decision_code := "DENY_DEFAULT"

# Decision code resolution
decision_code := "ALLOW_ADMIN_OVERRIDE" if {
	is_admin
} else := "ALLOW_RESOURCE_OWNER" if {
	is_owner_allowed
} else := "ALLOW_ROLE_PERMITTED" if {
	is_role_permitted
} else := "DENY_CROSS_TENANT_ACCESS" if {
	is_cross_tenant
} else := "DENY_INSUFFICIENT_ROLE" if {
	not is_admin
	not is_role_permitted
	not is_owner_allowed
}

# Reasons resolution
reasons := [reason] if {
	reason != "unknown"
} else := []

# Main allow rule
allow if {
	is_admin
}

allow if {
	is_role_permitted
}

allow if {
	is_owner_allowed
}

# Admin can do anything
is_admin if {
	"admin" in input.subject.roles
}

# Role-action matrix
is_role_permitted if {
	some role in input.subject.roles
	some action in data.authz.role_actions[role]
	action == input.action
	same_tenant
}

# Owner can manage their own resource
is_owner_allowed if {
	input.action in {"read", "update", "delete"}
	input.resource.owner_id == input.subject.user_id
	same_tenant
}

same_tenant if {
	input.resource.tenant == input.subject.tenant
}

is_cross_tenant if {
	input.resource.tenant != input.subject.tenant
}

default reason := "unknown"

reason := "admin role granted full access" if {
	is_admin
} else := sprintf("resource owner %s authorized for %s action", [input.subject.user_id, input.action]) if {
	is_owner_allowed
} else := sprintf("action %s permitted by assigned roles", [input.action]) if {
	is_role_permitted
} else := sprintf("cross-tenant access denied (subject: %s, resource: %s)", [input.subject.tenant, input.resource.tenant]) if {
	is_cross_tenant
} else := sprintf("action %s not permitted for roles %v", [input.action, input.subject.roles]) if {
	not is_role_permitted
}
