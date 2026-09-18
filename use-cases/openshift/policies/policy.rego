package openshift

import rego.v1

default allowed := false
default decision_code := "DENY_DEFAULT"

# Decision code resolution
decision_code := "ALLOW_REGISTRY_INTERNAL" if {
	internal_registry_matched
} else := "ALLOW_REGISTRY_EXCEPTION" if {
	valid_exception_active
} else := "DENY_EXCEPTION_EXPIRED" if {
	exception_expired_match
} else := "DENY_EXCEPTION_NO_TICKET" if {
	exception_missing_ticket
} else := "DENY_REGISTRY_UNAUTHORIZED" if {
	not internal_registry_matched
	not any_exception_matched
}

# Reasons resolution
reasons := [reason] if {
	reason != "unknown"
} else := []

# Main allow rule
allowed if {
	internal_registry_matched
}

allowed if {
	valid_exception_active
}

internal_registry_matched if {
	some prefix in data.openshift.allowed_prefixes
	startswith(input.image, prefix)
}

valid_exception_active if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
	is_string(ex.ticket)
	ex.ticket != ""
	not exception_expired(ex)
}

exception_expired_match if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
	exception_expired(ex)
}

exception_missing_ticket if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
	not valid_ticket(ex)
}

any_exception_matched if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
}

exception_expired(ex) if {
	ex.expires
	time.parse_rfc3339_ns(ex.expires) < time.now_ns()
}

valid_ticket(ex) if {
	is_string(ex.ticket)
	ex.ticket != ""
}

default reason := "unknown"

reason := "image originates from allowed internal registry" if {
	internal_registry_matched
} else := sprintf("valid exception ticket %s applied", [ticket_of_active_exception]) if {
	valid_exception_active
} else := sprintf("exception for %q expired on %s", [input.image, expired_date]) if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
	exception_expired(ex)
	expired_date := ex.expires
} else := sprintf("exception for %q requires a valid ticket", [input.image]) if {
	exception_missing_ticket
} else := sprintf("image %q is not from an allowed registry", [input.image]) if {
	not internal_registry_matched
	not any_exception_matched
}

ticket_of_active_exception := ex.ticket if {
	some ex in data.openshift.exceptions
	startswith(input.image, ex.prefix)
	valid_ticket(ex)
	not exception_expired(ex)
}
