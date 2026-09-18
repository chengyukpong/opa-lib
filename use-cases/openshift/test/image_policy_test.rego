package openshift.test

import rego.v1
import data.openshift.allowed
import data.openshift.decision_code
import data.envelope

test_internal_image_allowed if {
	mock_input := {
		"image": "registry.internal.acme/orders:1.0.0",
		"namespace": "prod",
	}

	allowed with input as mock_input
	decision_code == "ALLOW_REGISTRY_INTERNAL" with input as mock_input

	# Verify envelope export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_REGISTRY_INTERNAL" with input as mock_input
}

test_external_image_denied if {
	mock_input := {
		"image": "docker.io/library/nginx:1.25",
		"namespace": "prod",
	}

	not allowed with input as mock_input
	decision_code == "DENY_EXCEPTION_NO_TICKET" with input as mock_input

	# Verify envelope export
	envelope.allowed == false with input as mock_input
	envelope.code == "DENY_EXCEPTION_NO_TICKET" with input as mock_input
}

test_exception_with_ticket_allowed if {
	mock_input := {
		"image": "quay.io/acme-legacy/old-app:1.0",
		"namespace": "legacy",
	}

	allowed with input as mock_input
	decision_code == "ALLOW_REGISTRY_EXCEPTION" with input as mock_input

	# Verify envelope export
	envelope.allowed == true with input as mock_input
	envelope.code == "ALLOW_REGISTRY_EXCEPTION" with input as mock_input
}
