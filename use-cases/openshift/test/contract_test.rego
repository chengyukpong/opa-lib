package openshift.contract_test

import rego.v1
import data.common.contract

# Validate that this use-case fully complies with the corporate SPI contract (package envelope)
test_spi_contract_compliance if {
	mock_input := {
		"image": "registry.internal.acme/orders:1.0.0",
		"namespace": "prod",
	}

	contract.compliance_errors == set() with input as mock_input
	contract.is_compliant == true with input as mock_input
}
