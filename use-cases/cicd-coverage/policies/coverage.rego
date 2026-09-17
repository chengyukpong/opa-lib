package ci

import rego.v1

default pass := false
default reason := "unknown"

# Explicit waiver (temporary exemption)
pass if {
	some w in data.waivers
	w.repo == input.repo
	is_string(w.ticket)
	w.ticket != ""
	not waiver_expired(w)
}

reason := "waiver" if {
	some w in data.waivers
	w.repo == input.repo
	is_string(w.ticket)
	w.ticket != ""
	not waiver_expired(w)
}

# Coverage threshold by language profile
pass if {
	threshold := data.thresholds[input.language]
	input.coverage_pct >= threshold
	not waiver_expired_for(input.repo)
}

reason := sprintf("coverage %s%% >= threshold %s%%", [format_int(input.coverage_pct, 10), format_int(threshold, 10)]) if {
	threshold := data.thresholds[input.language]
	input.coverage_pct >= threshold
}

reason := sprintf("coverage %s%% < threshold %s%%", [format_int(input.coverage_pct, 10), format_int(threshold, 10)]) if {
	threshold := data.thresholds[input.language]
	input.coverage_pct < threshold
	not waiver_ok(input.repo)
}
