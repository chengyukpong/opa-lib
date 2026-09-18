# OPA Policy Library (`opa-lib`)

> **Note**: This repository serves as a reference demonstration showcasing enterprise best practices for Open Policy Agent (OPA). It demonstrates scalable architecture patterns including corporate decision envelope standardization, SPI contract testing, multi-bundle deployment, and strict namespace isolation.

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

## Directory Layout & Namespace Design

```text
├── use-cases/
│   ├── common/                       # Shared interfaces and envelope definitions
│   │   ├── .manifest                 # roots: ["common"]
│   │   ├── common/
│   │   │   ├── meta.json             # Mounted at data.common.meta
│   │   │   └── schemas/              # Mounted at data.common.schemas
│   │   │       └── response.json
│   │   └── policies/                 # Package common.*
│   │       ├── contract.rego
│   │       ├── decision.rego
│   │       └── schema.rego
│   ├── cicd-coverage/
│   │   ├── .manifest                 # roots: ["cicd_coverage", "envelope"]
│   │   ├── cicd_coverage/            # Mounted at data.cicd_coverage.*
│   │   │   ├── data.json
│   │   │   └── meta.json
│   │   ├── policies/
│   │   │   ├── coverage.rego         # Package cicd_coverage
│   │   │   ├── waiver.rego           # Package cicd_coverage
│   │   │   └── envelope_adapter.rego # Package envelope (implements SPI)
│   │   └── test/                     # Excluded during bundle packaging
│   │       ├── fixtures.yaml
│   │       ├── fixtures_test.rego
│   │       ├── coverage_test.rego
│   │       └── contract_test.rego
│   ├── openshift/
│   │   ├── .manifest                 # roots: ["openshift", "envelope"]
│   │   ├── openshift/                # Mounted at data.openshift.*
│   │   │   ├── data.json
│   │   │   └── meta.json
│   │   ├── policies/
│   │   │   ├── policy.rego           # Package openshift
│   │   │   └── envelope_adapter.rego # Package envelope (implements SPI)
│   │   └── test/
│   │       ├── fixtures.yaml
│   │       ├── fixtures_test.rego
│   │       ├── image_policy_test.rego
│   │       └── contract_test.rego
│   └── authz/
│       ├── .manifest                 # roots: ["authz", "envelope"]
│       ├── authz/                    # Mounted at data.authz.*
│       │   ├── data.json
│       │   └── meta.json
│       ├── policies/
│       │   ├── policy.rego           # Package authz
│       │   └── envelope_adapter.rego # Package envelope (implements SPI)
│       └── test/
│           ├── fixtures.yaml
│           ├── fixtures_test.rego
│           ├── authz_test.rego
│           └── contract_test.rego
├── input-sets/                       # Standalone input payloads for opa exec testing
│   ├── cicd-coverage/
│   ├── openshift/
│   └── authz/
├── config.yaml                       # Global runtime config (defines default_decision)
└── opa.exe                           # OPA runtime binary
```

### Namespace Isolation & Manifest Root Convergence
To support multi-team independent maintenance and bundle publishing (Multi-Bundle Architecture), this repository follows the **Namespace Convergence and Isolation Principle**:
1. **Path-as-Namespace**:
   - Static data, metadata, and JSON schemas are placed in domain-matching subdirectories (e.g. `common/common/meta.json` mounts under `data.common.meta`, `common/schemas/response.json` mounts under `data.common.schemas`, `cicd_coverage/data.json` mounts under `data.cicd_coverage.*`).
   - Avoid placing non-namespaced JSON files directly at the use-case root directory to prevent merge conflicts (`Merge Error`) when multiple bundles are loaded into `data.*` simultaneously.
2. **Minimal Manifest Roots**:
   - Through directory convergence, the `common` bundle only needs to declare a single root: `["common"]`.
   - Each business usecase bundle only declares its business namespace and the SPI adapter namespace (e.g. `["cicd_coverage", "envelope"]`).
3. **Conflict-Free Multi-Bundle Composition**:
   - OPA can seamlessly load both the Practice Team's common bundle and domain usecase bundles with cleanly partitioned root paths.

---

## 1. Running Tests (`opa test`)

Run native unit and fixture tests using `opa test`.

### Test a Single Use Case
```bash
# Test specific use case with verbose output
.\opa.exe test -v use-cases/cicd-coverage use-cases/common

# With coverage report
.\opa.exe test -v --coverage use-cases/cicd-coverage use-cases/common

# Run benchmarks
.\opa.exe test --bench use-cases/openshift use-cases/common
```

### Test All Policy Suites
```bash
.\opa.exe test -v use-cases/cicd-coverage use-cases/common
.\opa.exe test -v use-cases/openshift use-cases/common
.\opa.exe test -v use-cases/authz use-cases/common
```

---

## 2. Interactive Evaluation (`opa eval`)

Evaluate standard `common/decision/response` envelopes or specific rules using `opa eval`.

### Standard Response Evaluation
```cmd
:: Evaluate CI/CD coverage standard response
opa.exe eval --data use-cases/cicd-coverage --data use-cases/common --input input-sets/cicd-coverage/thresholds/ts-pass.yaml "data.common.decision.response"

:: Evaluate OpenShift registry standard response
opa.exe eval --data use-cases/openshift --data use-cases/common --input input-sets/openshift/basics/internal-ok.yaml "data.common.decision.response"

:: Evaluate Authz API standard response
opa.exe eval --data use-cases/authz --data use-cases/common --input input-sets/authz/matrix/admin-delete.yaml "data.common.decision.response"
```

---

## 3. Building & Executing Bundles (`opa build` & `opa exec`)

You can build and execute use cases either as **independent multi-bundles** (Production Model) or as a **single merged bundle**.

### Multi-Bundle Model (Recommended for Practice Team Setup)
Each bundle declares its non-overlapping `.manifest` roots (`roots: ["common"]` vs `roots: ["cicd_coverage", "envelope"]`).

```cmd
:: 1. Build independent bundles
opa.exe build -b use-cases/common -o common.tar.gz
opa.exe build --ignore test -b use-cases/cicd-coverage -o cicd-coverage.tar.gz

:: 2. Exec with multiple bundles (Single-line for Windows CMD)
opa.exe exec -c config.yaml --bundle cicd-coverage.tar.gz --bundle common.tar.gz input-sets/cicd-coverage/thresholds/ts-pass.yaml
```
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
