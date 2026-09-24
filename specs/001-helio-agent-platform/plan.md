# Implementation Plan: Helio Agent Platform

**Branch**: `speckit` | **Date**: 2026-09-24 |
**Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-helio-agent-platform/spec.md`.
This plan ends at Phase 1 design. It does not create source code or implementation tasks.

## Summary

Helio lets a Product Owner define a greenfield or brownfield project, accept a
specification through the selected mode, inspect two roadmaps, and run controlled
agent pipelines. A Tech Lead can reconstruct an existing project, compare isolated
strategies, inspect evidence, and prepare prototypes and environments. Strategy
comparison uses one immutable accepted specification revision, whether acceptance
was manual in normal mode or automatic after passing checks in an authorized
autonomous or sandbox mode. The first delivery is a modular Python control plane
with a contract-first API, an HTMX
dashboard, one owner for DuckDB writes, and isolated workers. Project roles and
provider policy guard all run actions and outbound data. A guided local bootstrap
creates the first operator without a default credential. Project-specific source
labels and task scopes block unclassified external transfers. A synchronous paid-token
ledger permits configured free-local fallback or a durable pending checkpoint for
later resumption of the same run. Each external harness, knowledge tool, model
runtime, and deployment target enters through an adapter. See [research.md](research.md)
for decisions and rejected alternatives.

## Technical Context

**Language/Version**: Python 3.13+ for control plane and adapters. HTML and CSS for
server-rendered dashboard. Shell and Makefile for guided local setup.

**Primary Dependencies**: FastAPI HTTP adapter, HTMX, DuckDB, Git worktrees, Docker
Compose, OpenTelemetry, Langfuse, and the agreed `swaggerapi/swagger-generator`
service for contract generation checks. Open WebUI, Pi, Devin, Graphify, OpenKB,
AG-UI, A2UI, decidr, and model runtimes are bounded adapters, enabled after their
capabilities are validated.

**Storage**: One DuckDB file with one write-owner process for operational state,
project permissions, provider-transfer decisions, paid-token reservations, and
resumable checkpoints; versioned repository/worktree files and artifact references
for source, prototypes, and generated documents. Raw credentials stay in a secret provider or local secure
configuration, outside project records.

**Testing**: pytest for domain and adapter behavior; contract validation and
generated-client checks; fixture harnesses for deterministic pipeline tests;
Compose end-to-end scenarios on macOS and WSL2; project authorization and transfer
denial fixtures; concurrent quota, fallback, and session-resume fixtures; target
prerequisite checks and CloudFormation change-set review for AWS. LLM evaluator
checks require a recorded rubric and threshold.

**Target Platform**: Local macOS and Windows WSL2 with Docker Desktop and Compose;
AWS target definitions through CloudFormation for Dev, Pre, or Pro. Local, Dev, Pre,
and Pro are configuration stages, not a fixed cloud topology.

**Project Type**: Web dashboard plus machine API and isolated agent workers.

**Performance Goals**: Persist each run event before presenting a state transition;
show current agent state and recover missed events after reconnect. No throughput,
latency, or concurrency target was supplied. Establish those targets from pilot
runs before selecting production topology.

**Constraints**: API-first, DDD, Hexagonal Architecture, modular boundaries, Spanish
user messages and English stored artifacts, ShadCN visual style without required
React components, corporate CA and artifact authentication, source-backed brownfield
reconstruction, project-scoped permissions, approved-provider egress, mode-specific
specification acceptance, automatic brownfield baseline checks, independent
verification, bounded retries, traceable decisions, resumable quota checkpoints,
and no accepted failing regressions.

**Scale/Scope**: Six user stories, 25 functional requirements, and 12 success
criteria. Initial design supports one control-plane write owner and multiple
isolated run workspaces. A production scale target is not specified.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Rule | Before research | After design | Evidence |
| --- | --- | --- | --- |
| I. Spanish user communication; English stored work | Pass | Pass | [UI contract](contracts/ui.md) defines language and accessibility; these artifacts are in English. |
| II. Clean scoped context and independent verification | Pass | Pass | [Runtime port](contracts/agent-runtime.md), [data model](data-model.md), and [quickstart](quickstart.md) preserve attempts and verifier evidence. |
| II. Deterministic checks first; recorded judge criteria | Pass | Pass | GateDefinition and GateResult require fixtures or rubric plus threshold. A missing threshold blocks pipeline publication. |
| III. API-first, DDD, Hexagonal Architecture | Pass | Pass | [Machine API](contracts/openapi.yaml) precedes implementation; planned modules isolate domain, ports, and adapters. |
| III. Public contract impact and migration | Pass | Pass | Versioned API and pipeline records; contract changes require compatibility review and a migration guide. |
| III. Brownfield baseline and regression proof | Pass | Pass | Automatic baseline checks accept only passing versions; [quickstart](quickstart.md) tests conflict and regression paths. |
| Agreed local and enterprise constraints | Pass | Pass | [Research](research.md) records feasibility and adapter decisions; [quickstart](quickstart.md) defines local checks. |
| Review and exception evidence | Pass | Pass | Run events, mode-specific acceptance decisions, and override records are retained in the [data model](data-model.md). |
| Clarified project access and egress | Pass | Pass | [API](contracts/openapi.yaml), [runtime port](contracts/agent-runtime.md), [Open WebUI boundary](contracts/open-webui.md), and [quickstart](quickstart.md) cover first-operator bootstrap, project roles, source classification, task grants, provider approvals, and transfer audit. |
| Clarified paid-token quota | Pass | Pass | [Data model](data-model.md), [events](contracts/events.md), and [quickstart](quickstart.md) cover atomic reservations, eligible local fallback, pending checkpoint, and authorized resume. |

These design-conformance results do not record Product Owner or Tech Lead approval.
The pre-implementation T123 review remains pending in
[implementation-readiness.md](../../docs/helio/implementation-readiness.md).
No constitutional violation is required by this design. Ratification and governance
authority TODOs in the constitution remain project governance work; they do not
justify bypassing the technical gates. External credentials and model artifacts are
validated at installation or run time.

## Project Structure

### Documentation (this feature)

```text
specs/001-helio-agent-platform/
├── spec.md
├── checklists/
│   └── requirements.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    ├── openapi.yaml
    ├── events.md
    ├── ui.md
    └── agent-runtime.md
```

### Source Code (repository root)

The following is the planned implementation layout. No application files are
created by this plan.

```text
src/helio/
├── domain/
│   ├── projects/
│   ├── access/
│   ├── planning/
│   ├── pipelines/
│   ├── execution/
│   ├── knowledge/
│   └── environments/
├── application/
│   ├── commands/
│   ├── queries/
│   └── ports/
└── adapters/
    ├── http_api/
    ├── dashboard/
    │   ├── templates/
    │   └── static/
    ├── persistence_duckdb/
    ├── identity_and_secrets/
    ├── agent_pi/
    ├── agent_devin/
    ├── knowledge_graphify/
    ├── knowledge_openkb/
    ├── telemetry/
    └── deployment/
tests/
├── contract/
├── integration/
├── domain/
└── end_to_end/
deploy/
├── local/
└── aws/
Makefile
```

**Structure Decision**: One modular control plane owns domain state. HTTP, dashboard,
harness, persistence, knowledge, telemetry, and deployment integrations are adapters.
Agent processes and prototype stacks run separately. `deploy/local/` avoids
overwriting the repository's existing root Compose file, which belongs to the
current Spec Kit development setup.

## Delivery Sequence and Estimate Inputs

| Slice | User outcome | Dependency | Human work that can overlap | Agent work that can overlap |
| --- | --- | --- | --- | --- |
| Foundation | Contract, local installer and operator bootstrap, state owner, event and evidence model | Pre-implementation readiness review | DevOps setup and UX tokens can proceed with backend domain work | Contract, UI, and fixture research can run in parallel |
| Intake | Guided interview, mode-specific specification acceptance, both roadmaps | Foundation | PO acceptance review and UX can overlap backend intake work | Independent spec generation and verification; automatic acceptance waits for all required checks |
| Pipelines | Catalog, run engine, project access, data classification, provider policy, quota ledger, gates, monitoring | Foundation; accepted spec for live use | Agent adapters and access UI can proceed in parallel after runtime port is fixed | Stage branches run in parallel; quota reservations are serialized; joins and gates block progress |
| Brownfield | Multi-repo baseline and automatic checks | Foundation | Repository parsing and evidence UI can proceed together | Per-repository extraction can run in parallel; required checks block acceptance until all pass |
| Comparison and prototypes | Isolated strategies and review stacks | Pipelines | Comparison UI and Compose isolation can proceed together | Strategies run in parallel; comparison waits for terminal results |
| Environments and knowledge | Deployment validation and living project record | Foundation; run evidence for trace links | Knowledge and environment adapters can proceed together | Source indexing and trace export can run asynchronously |

The human estimate model uses the stated full-time squad: Product Owner, Tech Lead,
two Backend engineers, DevOps engineer, and Frontend/UX/QA engineer. It sums effort
by role on the dependency graph and uses the longest role-constrained path for
elapsed time. The agent estimate model sums expected stage duration and model tokens
on the critical path, adds bounded retry and judge calls, and reserves concurrent
paid calls against the user-set paid-token quota. Parallel branches contribute their
maximum elapsed time and combined token use. A configured eligible free-local fallback
adds a separately estimated path. Without one, quota exhaustion puts the run in
pending state; waiting for an authorized quota increase is unknown and is shown
separately from active execution time. Numeric durations and costs require task
breakdown, pilot timings, chosen models, price data, and budget. None were supplied,
so the plan records the calculation method instead of an unsupported calendar promise.

## Complexity Tracking

No constitutional violation or exception is requested. The modular control plane
and adapter layout are the simplest design that preserves the stated API, workflow,
and brownfield boundaries. A later move to multiple state writers or a different
contract generator requires a recorded architecture decision and governance review.
