
package cicd_coverage

import rego.v1

default pass := false
default decision_code := "DENY_DEFAULT"

# Decision code resolution
decision_code := "ALLOW_WAIVER" if {
	waiver_active
} else := "ALLOW_THRESHOLD_MET" if {
	threshold_met
} else := "DENY_WAIVER_EXPIRED" if {
	waiver_expired_for(input.repo)
} else := "DENY_COVERAGE_BELOW_THRESHOLD" if {
	threshold := data.cicd_coverage.thresholds[input.language]
	input.coverage_pct < threshold
}

# Reasons resolution
reasons := [reason] if {
	reason != "unknown"
} else := []

# Explicit waiver (temporary exemption)
pass if {
	waiver_active
}

waiver_active if {
	some w in data.cicd_coverage.waivers
	w.repo == input.repo
	is_string(w.ticket)
	w.ticket != ""
	not waiver_expired(w)
}

# Coverage threshold by language profile
pass if {
	threshold_met
	not waiver_expired_for(input.repo)
}

threshold_met if {
	threshold := data.cicd_coverage.thresholds[input.language]
	input.coverage_pct >= threshold
}

default reason := "unknown"

reason := "waiver active" if {
	waiver_active
} else := sprintf("waiver expired for repo %s", [input.repo]) if {
	waiver_expired_for(input.repo)
} else := sprintf("coverage %s%% >= threshold %s%%", [format_int(input.coverage_pct, 10), format_int(threshold, 10)]) if {
	threshold := data.cicd_coverage.thresholds[input.language]
	input.coverage_pct >= threshold
} else := sprintf("coverage %s%% < threshold %s%%", [format_int(input.coverage_pct, 10), format_int(threshold, 10)]) if {
	threshold := data.cicd_coverage.thresholds[input.language]
	input.coverage_pct < threshold
}
