package envelope

import rego.v1
import data.authz

# Implement the standard data.envelope contract
allowed := authz.allow
code := authz.decision_code
reasons := authz.reasons
metadata := {
	"policy_id": "authz",
	"version": "1.0.0",
}
