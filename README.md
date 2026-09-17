# OPA Policy Library (`opa-lib`)

A standardized, zero-dependency Open Policy Agent (OPA) policy repository featuring enterprise use-cases, native Rego testing, and standardized decision interfaces.

---

## Standard Decision Interface & SPI Contract

All enterprise policy bundles must conform to the **Corporate SPI Contract (`package policy`)** which is automatically encapsulated by the unified **Decision Envelope (`data.common.decision.response`)**:

### 1. SPI Implementation Contract (`package policy`)
Each policy bundle must declare `package policy` (typically in `policies/policy_adapter.rego` or `policies/main.rego`) exporting:
- `allowed` (`boolean`): Whether the request passes.
- `code` (`string`): Standard decision code (e.g. `ALLOW_THRESHOLD_MET`, `DENY_EXPIRED`).
- `reasons` (`array` or `set`): Explanatory reasons.
- `metadata` (`object`): Containing `policy_id` and `version`.

### 2. Standard Decision Response Envelope (`data.common.decision.response`)
```json
{
  "allowed": true,
  "decision_code": "ALLOW_THRESHOLD_MET",
  "reasons": [
    "coverage 85% >= threshold 80%"
  ],
  "timestamp_ns": 1789632745913201200,
  "metadata": {
    "policy_id": "cicd-coverage",
    "version": "1.0.0"
  }
}
```

---

## Directory Layout

```text
├── use-cases/
│   ├── common/                   # Shared interfaces and envelope definitions
│   │   ├── meta.json
│   │   └── policies/
│   │       └── decision.rego     # Standard decision response definition
│   ├── cicd-coverage/
│   ├── openshift-image-registry/
│   └── rbac-api/
│       ├── meta.json             # Usecase metadata & query entrypoint
│       ├── data.json             # Base data mounted at root `data.*`
│       ├── policies/             # Production Rego policy rules
│       │   └── *.rego
│       └── test/                 # Test suites & fixtures (excluded during bundle build)
│           ├── fixtures.yaml     # Table-driven test cases
│           ├── fixtures_test.rego
│           └── *_test.rego       # Unit test cases
├── input-sets/                   # Standalone input payloads for opa exec testing
│   ├── cicd-coverage/
│   ├── openshift-image-registry/
│   └── rbac-api/
└── opa.exe                       # OPA runtime binary
```

---

## 1. Running Tests (`opa test`)

Run native unit and fixture tests using `opa test`. Include `use-cases/common/policies` for packages that implement standard decision interfaces.

### Test a Single Use Case
```bash
# Test specific use case with verbose output
.\opa.exe test -v use-cases/cicd-coverage use-cases/common/policies

# With coverage report
.\opa.exe test -v --coverage use-cases/cicd-coverage use-cases/common/policies

# Run benchmarks
.\opa.exe test --bench use-cases/openshift-image-registry
```

### Test All Policy Suites
```bash
.\opa.exe test -v use-cases/cicd-coverage use-cases/common/policies
.\opa.exe test -v use-cases/openshift-image-registry
.\opa.exe test -v use-cases/rbac-api
```

---

## 2. Interactive Evaluation (`opa eval`)

Evaluate standard `common/decision/response` envelopes or specific rules using `opa eval`.

### Standard Response Evaluation
```bash
# Evaluate CI/CD coverage standard response
.\opa.exe eval --data use-cases/cicd-coverage --data use-cases/common/policies \
  --input input-sets/cicd-coverage/thresholds/ts-pass.yaml \
  "data.common.decision.response"

# Evaluate RBAC decision rule
.\opa.exe eval --data use-cases/rbac-api \
  --input '{"subject":{"user_id":"u-admin","roles":["admin"],"tenant":"acme"},"action":"delete","resource":{"tenant":"acme","owner_id":"u-other","type":"invoice"}}' \
  "data.authz.allow"
```

---

## 3. Building & Executing Bundles (`opa build` & `opa exec`)

Build a production bundle containing the use case and common interface library, then run `opa exec` against it.

### Build Bundle
```bash
# Build bundle combining usecase policy and shared common interface
.\opa.exe build --ignore test -o bundle-cicd.tar.gz use-cases/cicd-coverage use-cases/common/policies
```

### Exec with Configuration File (`config.yaml`)
You can use `config.yaml` to specify the `default_decision` so you don't need to specify `--decision`:

```bash
# Exec using config.yaml without typing --decision
.\opa.exe exec -c use-cases/cicd-coverage/config.yaml \
  --bundle bundle-cicd.tar.gz \
  input-sets/cicd-coverage/thresholds/ts-pass.yaml
```
