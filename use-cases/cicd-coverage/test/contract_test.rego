package ci_contract_test

import rego.v1
import data.common.contract

# 驗證此 use-case 是否完全符合企業 SPI 契約 (package policy)
test_spi_contract_compliance if {
	mock_input := {
		"repo": "acme/web",
		"language": "typescript",
		"coverage_pct": 85,
	}

	contract.compliance_errors == set() with input as mock_input
	contract.is_compliant == true with input as mock_input
}
