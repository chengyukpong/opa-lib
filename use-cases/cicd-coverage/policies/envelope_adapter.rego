package envelope

import rego.v1
import data.cicd_coverage

# Implement the standard data.envelope contract
allowed := cicd_coverage.pass
code := cicd_coverage.decision_code
reasons := cicd_coverage.reasons
metadata := {
	"policy_id": "cicd-coverage",
	"version": "1.0.0",
}
