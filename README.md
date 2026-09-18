# OPA Policy Library (`opa-lib`)

A standardized, zero-dependency Open Policy Agent (OPA) policy repository featuring enterprise use-cases, native Rego testing, and standardized decision interfaces.

---

## Standard Decision Interface & SPI Contract

All enterprise policy bundles must conform to the **Corporate Envelope SPI Contract (`package envelope`)** which is automatically encapsulated by the unified **Decision Envelope (`data.common.decision.response`)**:

### 1. SPI Implementation Contract (`package envelope`)
Each policy bundle must declare `package envelope` (typically in `policies/envelope_adapter.rego`) exporting:
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
├── config.yaml                   # Global runtime config (defines default_decision)
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
```cmd
:: Evaluate CI/CD coverage standard response
opa.exe eval --data use-cases/cicd-coverage --data use-cases/common/policies --input input-sets/cicd-coverage/thresholds/ts-pass.yaml "data.common.decision.response"

:: Evaluate RBAC decision rule
opa.exe eval --data use-cases/rbac-api --input "{\"subject\":{\"user_id\":\"u-admin\",\"roles\":[\"admin\"],\"tenant\":\"acme\"},\"action\":\"delete\",\"resource\":{\"tenant\":\"acme\",\"owner_id\":\"u-other\",\"type\":\"invoice\"}}" "data.authz.allow"
```

---

## 3. Building & Executing Bundles (`opa build` & `opa exec`)

You can build and execute use cases either as **independent multi-bundles** (Production Model) or as a **single merged bundle**.

### Multi-Bundle Model (Recommended for Practice Team Setup)
Each bundle declares its non-overlapping `.manifest` roots (`roots: ["common", "schemas"]` vs `roots: ["ci", "envelope", "thresholds", "waivers"]`).

```cmd
:: 1. Build independent bundles
opa.exe build --ignore meta.json -b use-cases/common -o common.tar.gz
opa.exe build --ignore test -b use-cases/cicd-coverage -o cicd-coverage.tar.gz

:: 2. Exec with multiple bundles (Single-line for Windows CMD)
opa.exe exec -c config.yaml --bundle cicd-coverage.tar.gz --bundle common.tar.gz input-sets/cicd-coverage/thresholds/ts-pass.yaml
```

### Single Merged Bundle Model
```cmd
:: Build unified bundle
opa.exe build --ignore test -o bundle-cicd.tar.gz use-cases/cicd-coverage use-cases/common/policies

:: Exec unified bundle (Single-line for Windows CMD)
opa.exe exec -c config.yaml --bundle bundle-cicd.tar.gz input-sets/cicd-coverage/thresholds/ts-pass.yaml
```

---

## 4. Remote S3 Bundle Configuration (`config.s3.yaml`)

In enterprise production environments, bundles are often hosted on AWS S3 (or S3-compatible object storage like MinIO). OPA can automatically poll and download bundles from S3 without specifying `--bundle` on the command line.

### Example `config.s3.yaml`:
```yaml
default_decision: /common/decision/response

services:
  s3_bundle_repo:
    url: https://s3.ap-east-1.amazonaws.com/corp-opa-bundles
    credentials:
      s3_signing:
        # Uses AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, or IAM Role from environment
        environment_credentials: {}

bundles:
  # Practice Team shared bundle
  common:
    service: s3_bundle_repo
    resource: common/v1.0.0/common.tar.gz
    polling:
      min_delay_seconds: 60
      max_delay_seconds: 120

  # Application / Use-Case bundle
  cicd_coverage:
    service: s3_bundle_repo
    resource: cicd-coverage/v1.2.0/cicd-coverage.tar.gz
    polling:
      min_delay_seconds: 60
      max_delay_seconds: 120
```

### Running with S3 Bundles:
```cmd
:: OPA Server (auto-downloads and watches S3 bundles)
opa.exe run --server -c config.s3.yaml

:: One-shot Exec against S3 bundles
opa.exe exec -c config.s3.yaml input-sets/cicd-coverage/thresholds/ts-pass.yaml
```
