package common.decision

import rego.v1

# Standard Company Decision Envelope (Evaluated against data.policy)
response := {
	"allowed": allowed,
	"decision_code": decision_code,
	"reasons": reasons,
	"timestamp_ns": time.now_ns(),
	"metadata": metadata,
}

# Defaults
default allowed := false
default decision_code := "DENY_DEFAULT"
default reasons := []
default metadata := {
	"policy_id": "unknown-policy",
	"version": "1.0.0",
}

# Resolve allowed state
allowed := data.policy.allowed if {
	is_boolean(data.policy.allowed)
}

# Resolve decision_code
decision_code := data.policy.code if {
	is_string(data.policy.code)
} else := "ALLOW_OK" if {
	allowed
} else := "DENY_DEFAULT"

# Resolve reasons
reasons := data.policy.reasons if {
	is_array(data.policy.reasons)
} else := [r | some r in data.policy.reasons] if {
	is_set(data.policy.reasons)
} else := []

# Metadata resolution
metadata := data.policy.metadata if {
	is_object(data.policy.metadata)
} else := {
	"policy_id": "unknown-policy",
	"version": "1.0.0",
}
