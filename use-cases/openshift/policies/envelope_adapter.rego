package envelope

import rego.v1
import data.openshift

# Implement the standard data.envelope contract
allowed := openshift.allowed
code := openshift.decision_code
reasons := openshift.reasons
metadata := {
	"policy_id": "openshift",
	"version": "1.0.0",
}
