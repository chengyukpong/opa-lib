package common.decision

import rego.v1

# Standard Company Decision Envelope (Evaluated against data.envelope)
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
allowed := data.envelope.allowed if {
	is_boolean(data.envelope.allowed)
}

# Resolve decision_code
decision_code := data.envelope.code if {
	is_string(data.envelope.code)
} else := "ALLOW_OK" if {
	allowed
} else := "DENY_DEFAULT"

# Resolve reasons
reasons := data.envelope.reasons if {
	is_array(data.envelope.reasons)
} else := [r | some r in data.envelope.reasons] if {
	is_set(data.envelope.reasons)
} else := []

# Metadata resolution
metadata := data.envelope.metadata if {
	is_object(data.envelope.metadata)
} else := {
	"policy_id": "unknown-policy",
	"version": "1.0.0",
}
