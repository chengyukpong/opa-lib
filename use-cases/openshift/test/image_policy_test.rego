package openshift.test

import rego.v1
import data.openshift.allowed
import data.common.decision.response
import data.common.schema

test_internal_image_allowed if {
	allowed with input as {
		"image": "registry.internal.acme/orders:1.0.0",
		"namespace": "prod",
	}

	res := response with input as {
		"image": "registry.internal.acme/orders:1.0.0",
		"namespace": "prod",
	}
	res.allowed == true
	res.decision_code == "ALLOW_REGISTRY_INTERNAL"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_external_image_denied if {
	not allowed with input as {
		"image": "docker.io/library/nginx:1.25",
		"namespace": "prod",
	}

	res := response with input as {
		"image": "docker.io/library/nginx:1.25",
		"namespace": "prod",
	}
	res.allowed == false
	res.decision_code == "DENY_EXCEPTION_NO_TICKET"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}

test_exception_with_ticket_allowed if {
	allowed with input as {
		"image": "quay.io/acme-legacy/old-app:1.0",
		"namespace": "legacy",
	}

	res := response with input as {
		"image": "quay.io/acme-legacy/old-app:1.0",
		"namespace": "legacy",
	}
	res.allowed == true
	res.decision_code == "ALLOW_REGISTRY_EXCEPTION"

	schema_check := schema.validate_response(res)
	schema_check.valid == true
}
