package cicd_coverage

import rego.v1

waiver_ok(repo) if {
	some w in data.cicd_coverage.waivers
	w.repo == repo
	is_string(w.ticket)
	w.ticket != ""
	not waiver_expired(w)
}

waiver_expired(w) if {
	w.expires
	time.parse_rfc3339_ns(w.expires) < time.now_ns()
}

waiver_expired_for(repo) if {
	some w in data.cicd_coverage.waivers
	w.repo == repo
	waiver_expired(w)
}
