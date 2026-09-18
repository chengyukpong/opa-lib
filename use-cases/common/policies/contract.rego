# ==============================================================================
# 🏢 Corporate Policy Envelope SPI Contract (企業決策 Envelope SPI 契約規範)
#
# 任何接入企業決策系統的 Policy Bundle，必須在 `policies/` 下實作 `package envelope`
# 並強制導出以下規範欄位供 `data.common.decision.response` 統一封裝：
#
#   1. allowed  (boolean): 決策是否允許/通過
#   2. code     (string):  標準決策代碼 (例如 ALLOW_THRESHOLD_MET, DENY_EXPIRED)
#   3. reasons  (array):   判定理由列表 (字串陣列)
#   4. metadata (object):  必須包含 policy_id 與 version
#
# ==============================================================================
package common.contract

import rego.v1

# 檢查 policy bundle 是否符合企業 Envelope SPI 契約介面
compliance_errors contains "Missing required field: data.envelope.allowed (must be boolean)" if {
	not is_boolean(data.envelope.allowed)
}

compliance_errors contains "Missing required field: data.envelope.code (must be non-empty string)" if {
	not is_string(data.envelope.code)
}

compliance_errors contains "data.envelope.code cannot be empty string" if {
	is_string(data.envelope.code)
	trim_space(data.envelope.code) == ""
}

compliance_errors contains "Missing required field: data.envelope.reasons (must be array or set)" if {
	not is_array(data.envelope.reasons)
	not is_set(data.envelope.reasons)
}

compliance_errors contains "Missing required field: data.envelope.metadata (must be object)" if {
	not is_object(data.envelope.metadata)
}

compliance_errors contains "Missing required field: data.envelope.metadata.policy_id" if {
	is_object(data.envelope.metadata)
	not is_string(data.envelope.metadata.policy_id)
}

compliance_errors contains "Missing required field: data.envelope.metadata.version" if {
	is_object(data.envelope.metadata)
	not is_string(data.envelope.metadata.version)
}

# 契約合規性判定
is_compliant if {
	count(compliance_errors) == 0
}
