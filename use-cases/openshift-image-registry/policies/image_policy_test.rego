package image_policy_test

import rego.v1
import data.image_policy.allowed

test_internal_image_allowed if {
	allowed with input as {
		"image": "registry.internal.acme/orders:1.0.0",
		"namespace": "prod",
	}
}

test_external_image_denied if {
	not allowed with input as {
		"image": "docker.io/library/nginx:1.25",
		"namespace": "prod",
	}
}

test_exception_with_ticket_allowed if {
	allowed with input as {
		"image": "quay.io/acme-legacy/old-app:1.0",
		"namespace": "legacy",
	}
}
