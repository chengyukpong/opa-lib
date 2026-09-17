# ==============================================================================
# 🏢 Corporate Policy SPI Contract (企業決策 SPI 契約規範)
#
# 任何接入企業決策系統的 Policy Bundle，必須在 `policies/` 下實作 `package policy`
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

# 檢查 policy bundle 是否符合企業 SPI 契約介面
compliance_errors contains "Missing required field: data.policy.allowed (must be boolean)" if {
	not is_boolean(data.policy.allowed)
}

compliance_errors contains "Missing required field: data.policy.code (must be non-empty string)" if {
	not is_string(data.policy.code)
}

compliance_errors contains "data.policy.code cannot be empty string" if {
	is_string(data.policy.code)
	trim_space(data.policy.code) == ""
}

compliance_errors contains "Missing required field: data.policy.reasons (must be array or set)" if {
	not is_array(data.policy.reasons)
	not is_set(data.policy.reasons)
}

compliance_errors contains "Missing required field: data.policy.metadata (must be object)" if {
	not is_object(data.policy.metadata)
}

compliance_errors contains "Missing required field: data.policy.metadata.policy_id" if {
	is_object(data.policy.metadata)
	not is_string(data.policy.metadata.policy_id)
}

compliance_errors contains "Missing required field: data.policy.metadata.version" if {
	is_object(data.policy.metadata)
	not is_string(data.policy.metadata.version)
}

# 契約合規性判定
is_compliant if {
	count(compliance_errors) == 0
}
