package image_policy

import rego.v1

default allowed := false

# Allowed when image matches an allowed prefix, or a valid exception.
allowed if {
	some prefix in data.allowed_prefixes
	startswith(input.image, prefix)
}

allowed if {
	some ex in data.exceptions
	startswith(input.image, ex.prefix)
	is_string(ex.ticket)
	ex.ticket != ""
	not exception_expired(ex)
}

exception_expired(ex) if {
	ex.expires
	time.parse_rfc3339_ns(ex.expires) < time.now_ns()
}

# Machine-readable denial reasons (optional for UI)
deny_reasons contains msg if {
	not startswith_any(input.image, data.allowed_prefixes)
	not startswith_any(input.image, exception_prefixes)
	msg := sprintf("image %q is not from an allowed registry", [input.image])
}

deny_reasons contains msg if {
	some ex in data.exceptions
	startswith(input.image, ex.prefix)
	not valid_ticket(ex)
	msg := sprintf("exception for %q requires a ticket", [input.image])
}

valid_ticket(ex) if {
	is_string(ex.ticket)
	ex.ticket != ""
}

deny_reasons contains msg if {
	some ex in data.exceptions
	startswith(input.image, ex.prefix)
	exception_expired(ex)
	msg := sprintf("exception for %q expired on %s", [input.image, ex.expires])
}

startswith_any(image, prefixes) if {
	some p in prefixes
	startswith(image, p)
}

exception_prefixes contains ex.prefix if {
	some ex in data.exceptions
}
