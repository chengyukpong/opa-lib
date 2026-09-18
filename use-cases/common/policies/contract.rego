# ==============================================================================
# 🏢 Corporate Policy Envelope SPI Contract Specification
#
# Any policy bundle integrated into the corporate decision system must implement
# `package envelope` under `policies/` and export the following standardized fields
# for unified encapsulation by `data.common.decision.response`:
#
#   1. allowed  (boolean): Whether the decision passed/allowed
#   2. code     (string):  Standard decision code (e.g., ALLOW_THRESHOLD_MET, DENY_EXPIRED)
#   3. reasons  (array):   List of explanatory reason strings
#   4. metadata (object):  Must contain policy_id and version
#
# ==============================================================================
package common.contract

import rego.v1

# Verify whether a policy bundle satisfies the corporate Envelope SPI contract interface
compliance_errors contains "Missing required field: data.envelope.allowed (must be boolean)" if {
	not is_boolean(data.envelope.allowed)
}

compliance_errors contains "Missing required field: data.envelope.code (must be non-empty string)" if {
	not is_string(data.envelope.code)
}

compliance_errors contains "data.envelope.code cannot be empty string" if {
	is_string(data.envelope.code)
	trim_space(data.envelope.code) == ""
}

compliance_errors contains "Missing required field: data.envelope.reasons (must be array or set)" if {
	not is_array(data.envelope.reasons)
	not is_set(data.envelope.reasons)
}

compliance_errors contains "Missing required field: data.envelope.metadata (must be object)" if {
	not is_object(data.envelope.metadata)
}

compliance_errors contains "Missing required field: data.envelope.metadata.policy_id" if {
	is_object(data.envelope.metadata)
	not is_string(data.envelope.metadata.policy_id)
}

compliance_errors contains "Missing required field: data.envelope.metadata.version" if {
	is_object(data.envelope.metadata)
	not is_string(data.envelope.metadata.version)
}

# Contract compliance determination
is_compliant if {
	count(compliance_errors) == 0
}
