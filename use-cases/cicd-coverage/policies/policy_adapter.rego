package policy

import rego.v1
import data.ci

# Implement the standard data.policy contract
allowed := ci.pass
code := ci.decision_code
reasons := ci.reasons
metadata := {
	"policy_id": "cicd-coverage",
	"version": "1.0.0",
}
