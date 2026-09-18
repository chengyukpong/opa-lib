package common.schema

import rego.v1

# Helper rule to validate any decision response object against corporate schema
validate_response(resp) := {
	"valid": valid,
	"errors": errs,
} if {
	[valid, errs] := json.match_schema(resp, data.common.schemas)
}
