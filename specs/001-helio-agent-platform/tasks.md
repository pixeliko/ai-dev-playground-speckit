---

description: "Implementation tasks for the Helio Agent Platform"
---

# Tasks: Helio Agent Platform

**Input**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), and [quickstart.md](quickstart.md).

**Tests**: The specification explicitly requires deterministic quality checks, regression protection, and independently testable user stories. Contract, domain, integration, and end-to-end test tasks appear before their story implementation tasks. Use fixture harnesses for deterministic runs.

**Organization**: Tasks are grouped by user story. The existing root `compose.yaml` belongs to the Spec Kit development setup; Helio's runtime files go under `deploy/local/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with other marked tasks in the same dependency layer because they write different files and need no unfinished task.
- **[Story]**: User story from [spec.md](spec.md); setup, foundation, and polish tasks have no story label.
- Every task names its implementation or validation file. Paths are relative to the repository root.

## Path Conventions

- Application: `src/helio/`, with domain, application ports, and external adapters separated as in [plan.md](plan.md).
- Checks: `tests/contract/`, `tests/domain/`, `tests/integration/`, and `tests/end_to_end/`.
- Local runtime: `deploy/local/`; AWS definitions: `deploy/aws/`.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the Python package, reproducible local runtime, and contract toolchain without changing the existing Spec Kit Compose stack.

- [ ] T001 Create the `src/helio/` domain/application/adapters package skeleton and `tests/` package skeleton in `src/helio/__init__.py` and `tests/conftest.py`, following the tree in `specs/001-helio-agent-platform/plan.md`.
- [ ] T002 Define Python 3.13+ project metadata and pinned FastAPI, DuckDB, HTMX-serving, OpenTelemetry, Langfuse, and pytest dependencies in `pyproject.toml` and `uv.lock`; keep optional harness and cloud dependencies in separate extras.
- [ ] T003 [P] Add formatting, lint, type-check, and pytest configuration to `pyproject.toml`; make the checks runnable without external model access.
- [ ] T004 [P] Build the guided `make install`, `make doctor`, `make local-up`, `make local-down`, `make contract-check`, and `make verify` targets in `Makefile`, with Spanish operator prompts and English generated logs/documents.
- [ ] T005 [P] Add a distinct Compose project for API, dashboard, one DuckDB state owner, and fixture worker in `deploy/local/compose.yaml` and its image definition in `deploy/local/Dockerfile`; assign a configurable host port and retain state on `local-down`.
- [ ] T006 Implement guided prerequisite checks for Docker/Compose, Python, corporate CA, JFrog CLI authentication, npm, uv, Hugging Face access, and optional agent/model integrations in `scripts/install.py`; report missing items without inventing credentials or requiring every optional model to install.
- [ ] T007 [P] Create secret-reference and environment configuration loading in `src/helio/adapters/identity_and_secrets/config.py` and documented placeholders in `deploy/local/env.example`; never place raw credentials in project records or images.
- [ ] T008 Pin and invoke the agreed `swaggerapi/swagger-generator` image against `specs/001-helio-agent-platform/contracts/openapi.yaml` and generate a disposable client in `scripts/check_contract.py`; validate the Swagger 2.0 source and generated output without requiring unimplemented API operations. Do not treat FastAPI's generated OpenAPI 3.1 schema as the source contract.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the transaction, authorization, contract, and evidence boundaries needed by every story.

**Critical**: Complete this phase before story implementation. A story may use prepared fixtures but must not bypass project authorization or the state owner.

- [ ] T009 Write schema and transaction tests for one write-owner, append-before-view state changes, UTC timestamps, immutable revisions, and opaque public IDs in `tests/integration/test_state_owner.py`.
- [ ] T010 [P] Write contract tests for the Swagger 2.0 problem responses, `/health`, project-scoped 401/403 behavior, and JSON-versus-HTML content types in `tests/contract/test_core_api.py`.
- [ ] T011 [P] Define opaque IDs, UTC timestamps, immutable revision references, and typed domain errors in `src/helio/domain/common.py`; define shared DecisionRecord with context, choice, alternatives, rationale, author, source/affected refs in `src/helio/domain/knowledge/decision.py`, where alternatives may be empty only with a reason. Enforce "IDs are opaque strings. The API does not expose storage row numbers", "Timestamps are UTC instants", and "Every project-owned record has a project ID, creator, creation time, and last change time."
- [ ] T012 Define persistence, event log, artifact, clock, identity, secret, authorization, and outbound-transfer ports in `src/helio/application/ports/core.py`; keep DuckDB, HTTP, and harness types out of domain signatures.
- [ ] T013 Implement DuckDB schema and a single-process write-owner transaction queue in `src/helio/adapters/persistence_duckdb/state_owner.py`; workers submit commands and never write the DuckDB file directly.
- [ ] T014 Implement append-only events, unique sequence per run, immutable evidence references, and materialized current views in `src/helio/adapters/persistence_duckdb/event_store.py`; reject invalid transitions before publication.
- [ ] T015 [P] Implement authenticated operator identity and membership/grant permission checks through fixture-backed ports in `src/helio/adapters/identity_and_secrets/authorization.py`; persist concrete ProjectMembership in T025 and AgentGrant in T044.
- [ ] T016 Implement reusable authorization and error dependencies for project APIs in `src/helio/adapters/http_api/auth.py` and `src/helio/adapters/http_api/errors.py`; return 401 for missing identity, 403 for denied actions, and persist denial metadata without secrets.
- [ ] T017 [P] Implement secret-reference resolution and redaction for logs/traces in `src/helio/adapters/identity_and_secrets/secrets.py`; resolve only a stage's needed secrets and never store their values in domain entities.
- [ ] T018 [P] Create FastAPI composition, `/api/v1/health`, and domain-to-HTTP error mapping in `src/helio/adapters/http_api/app.py`; keep `/api/v1` JSON routes separate from `/dashboard` HTML routes.
- [ ] T019 [P] Create the base HTMX document and Spanish status/form vocabulary in `src/helio/adapters/dashboard/templates/base.html`, with semantic brand/ShadCN-style CSS tokens in `src/helio/adapters/dashboard/static/theme.css`; do not require React components.
- [ ] T020 Create fixture identities, repositories, harness events, clocks, and state-owner lifecycle for deterministic tests in `tests/conftest.py`; cover Owner, Tech Lead, runner, viewer, and task-limited agent identities.
- [ ] T021 Run and repair the foundational source/generator check and implemented `/health` and authorization contract subset through `make contract-check` and the foundation subset of `make verify` in `Makefile`; confirm the local stack's API and state-owner connectivity on the chosen host. Reserve all-operation runtime checks for T117.

**Checkpoint**: A local, authenticated control plane starts, validates its source contract, and persists ordered evidence through one state owner.

---

## Phase 3: User Story 1 - Define a Project Through a Guided Interview (Priority: P1) MVP

**Goal**: Create a greenfield project, resume its interview, generate a traceable specification, accept it according to mode, and inspect separate human and agent roadmaps without running agents. Covers FR-001 to FR-004 and FR-024.

**Independent Test**: Complete [quickstart Scenario A](quickstart.md) using one greenfield project. Verify trace links, unresolved answers, human and agent assumptions, normal-mode Owner/Tech Lead approval, and automatic acceptance only when every required check passes.

### Tests for User Story 1

- [ ] T022 [P] [US1] Write contract tests for `/projects`, interview answer/resume, specification creation/approval/evaluation, and roadmap endpoints in `tests/contract/test_intake_api.py` against `specs/001-helio-agent-platform/contracts/openapi.yaml`.
- [ ] T023 [P] [US1] Write domain tests for project ownership, interview revision, requirement traceability, immutable accepted specification revisions, and blocked failed/inconclusive acceptance checks in `tests/domain/test_intake.py`.
- [ ] T024 [P] [US1] Write the Spanish HTMX greenfield journey and two-roadmap acceptance test in `tests/end_to_end/test_greenfield_intake.py`, including normal and autonomous/sandbox modes.

### Implementation for User Story 1

- [ ] T025 [P] [US1] Model Project, ProjectMembership, and Interview records in `src/helio/domain/projects/model.py`: project kind is `greenfield` or `brownfield`, name is unique within an owner workspace, membership roles are Owner/Tech Lead/runner/viewer, and "One active Project Owner is required."
- [ ] T026 [P] [US1] Model InterviewAnswer, Specification, Requirement, AcceptanceCriterion, and AcceptanceDecision in `src/helio/domain/planning/model.py`: an unanswered item stays explicit; "A requirement is linked to at least one acceptance criterion before acceptance"; deterministic checks have a fixture/expected result, judge checks a rubric/threshold, accepted revisions are immutable, and automatic acceptance needs all passing checks.
- [ ] T027 [P] [US1] Model Roadmap and RoadmapItem in `src/helio/domain/planning/roadmap.py`: roadmap kind is `human` or `agent`, dependencies are acyclic, and parallel groups derive from that graph.
- [ ] T028 [US1] Implement create/list/get project and resumable interview commands with answer revisions and unresolved-question tracking in `src/helio/application/commands/intake.py`, using T025 and T026.
- [ ] T029 [US1] Generate source-linked specification revisions and persist mode, acceptance checks, evidence, and decision in `src/helio/application/commands/specifications.py`; normal mode requires Owner/Tech Lead approval, while autonomous/sandbox needs all project-defined checks passed and failed/inconclusive checks block acceptance.
- [ ] T030 [US1] Calculate separate human and agent critical paths in `src/helio/application/commands/roadmaps.py`: use the stated Product Owner, Tech Lead, two Backend, DevOps, and Frontend/UX/QA squad; show dependencies, blockers, time inputs, paid-token quota, model effort, retries, local fallback, and unknown pending time without inventing numeric estimates.
- [ ] T031 [US1] Implement `/projects`, `/projects/{projectId}`, and interview endpoints in `src/helio/adapters/http_api/intake.py`, enforcing project membership and the source contract's status/error shapes.
- [ ] T032 [US1] Implement specification list/create/approve/evaluate and roadmap generation endpoints in `src/helio/adapters/http_api/planning.py`, binding every decision to the exact specification revision and actor when human approval applies.
- [ ] T033 [US1] Implement project list, interview question fragment, specification review, and roadmap pages in `src/helio/adapters/dashboard/projects.py` and `src/helio/adapters/dashboard/templates/projects.html`; preserve prior answers on validation errors and show checks and sources.
- [ ] T034 [US1] Run T022-T024 and the Scenario A fixture in `tests/end_to_end/test_greenfield_intake.py`; reject run eligibility before normal-mode approval or after any failed/inconclusive automatic check, without requiring an agent run.

**Checkpoint**: US1 works without agent execution and is the MVP intake increment.

---

## Phase 4: User Story 2 - Configure and Run Agent Pipelines (Priority: P2)

**Goal**: Publish reusable profiles and bounded pipelines; run them with project-scoped permissions, approved-provider transfers, visible gates and events, and paid-quota fallback or checkpointed resumption. Covers FR-005 to FR-008, FR-020 to FR-023, and FR-025.

**Independent Test**: With an accepted fixture specification, execute [quickstart Scenarios B, F, and G](quickstart.md) using fake agents. Verify triage, parallel join, consensus, deterministic and judge gates, retry, denied egress, quota fallback, pending state, and same-run resume.

### Tests for User Story 2

- [ ] T035 [P] [US2] Write contract tests for agent profiles, pipeline publish, project memberships/provider policy/transfer audit, run start/control/quota, and run snapshots in `tests/contract/test_pipeline_api.py`.
- [ ] T036 [P] [US2] Write graph and gate tests in `tests/domain/test_pipeline.py`: reject unreachable exits, undefined joins, missing profiles, missing judge rubric/threshold, unbounded cycles, and harnesses without persistent-session support.
- [ ] T037 [P] [US2] Write fixture-harness integration tests for triage, parallel branches, consensus, independent clean-context verification, retries, timeouts, cancellation, and event replay in `tests/integration/test_pipeline_runtime.py`.
- [ ] T038 [P] [US2] Write concurrent paid-token reservation, unknown-usage hold, configured live-probed local fallback, quota-pending checkpoint, denied quota increase, and same-run resume tests in `tests/integration/test_quota_resume.py`.
- [ ] T039 [P] [US2] Write project-role, task-grant, approved-provider category, revoked policy, and allow/deny-before-dispatch audit tests in `tests/integration/test_project_egress.py`; assert transferred content and credentials never enter the audit log.

### Implementation for User Story 2

- [ ] T040 [P] [US2] Model AgentProfile and ModelCapability in `src/helio/domain/pipelines/catalog.py`: published profile versions are immutable; a profile selects only live-probed capabilities; billing class is `paid` or `free_local`; store provider/runtime, model ID, revision, checksum, license, and hardware need.
- [ ] T041 [P] [US2] Model Pipeline, PipelineStage, StageEdge, GateDefinition, and EscalationPolicy in `src/helio/domain/pipelines/graph.py`: "Published versions are immutable", fallback refs belong to the published workflow version, cycles require an explicit retry limit or budget rule, a judge gate needs a rubric and threshold before publishing, and escalation must terminate or enter a bounded pending state.
- [ ] T042 [P] [US2] Model Run, RunEvent, StageResult, GateResult, and ResourceUsage in `src/helio/domain/execution/model.py`: attempts are distinct, failed evidence is retained, gate passes require configured evidence and threshold, usage state is observed/estimated/unknown, "unknown is not zero", local tokens do not spend the paid quota, and a stage cannot pass until gate results are recorded.
- [ ] T043 [P] [US2] Model TokenReservation, QuotaChange, and RunCheckpoint in `src/helio/domain/execution/quota.py`: "Unknown usage holds the reservation until reconciled"; quota changes are append-only and cannot erase prior usage; only Owner/Tech Lead can raise quota; a checkpoint records session/workspace/completed-stage/pending-work/ledger refs without raw secrets.
- [ ] T044 [P] [US2] Model AgentGrant, ProviderPolicy, and TransferDecision in `src/helio/domain/access/model.py`: policies are immutable revisions, agent grants are task-scoped and expire, and a transfer decision records provider/purpose/categories/policy revision/time/reason but no content or credentials.
- [ ] T045 [US2] Implement profile versioning and publish validation in `src/helio/application/commands/agent_catalog.py`, rejecting unavailable harness, model, skill, or knowledge refs before profile publication.
- [ ] T046 [US2] Implement pipeline graph validation and publication in `src/helio/application/commands/pipelines.py`, using T040-T041; validate join predicates, bounded retries, gate evidence, local fallback refs, and resumable harness capability.
- [ ] T047 [US2] Implement project membership, task-scoped agent-grant, and provider-policy commands in `src/helio/application/commands/project_access.py`, using T044; require Owner/Tech Lead to assign roles or approve/revoke providers, keep grants within issuer permissions, and record rejected actions.
- [ ] T048 [US2] Implement a synchronous transfer-admission service in `src/helio/application/commands/egress.py`: check project approval and minimum task data category, persist allow/deny before dispatch, and apply the same check to telemetry export.
- [ ] T049 [P] [US2] Define the harness start/event/control/session-restore port and deterministic fake adapter in `src/helio/application/ports/agent_runtime.py` and `tests/fixtures/fake_harness.py`; terminal events differ from command acknowledgements and missing usage is `unknown`.
- [ ] T050 [P] [US2] Implement Pi JSONL RPC process isolation, terminal-event handling, cancellation, persistent session reopen, and model switch in `src/helio/adapters/agent_pi/runtime.py`; resolve a configured local Devin Enterprise token by secret reference when that provider is selected, and never use `--no-session` in a resumable workflow.
- [ ] T051 [P] [US2] Implement Devin authentication and lifecycle in `src/helio/adapters/agent_devin/runtime.py` behind the same port, with its own token scope and no assumed Pi-compatible protocol.
- [ ] T052 [P] [US2] Implement live model-capability probing and billing classification in `src/helio/adapters/agent_pi/model_registry.py`; support Ollama where verified, identify the named Devstral Small 24B, Cactus Needle 3, Nemotron-3-Embed-8B-BF16, Qwen3-TTS, and VibeVoice 7B assets without assuming one runtime or mandatory installation.
- [ ] T053 [US2] Implement append-only run scheduling, triage, sequential/parallel edges, consensus joins, bounded retries, and clean-context independent verification in `src/helio/application/commands/run_engine.py`; route every external dispatch through T048 egress admission, assess decidr for bounded local triage only with calibration evidence or deterministic fallback, and persist stage events before publishing current state.
- [ ] T054 [US2] Implement deterministic gate evaluation and recorded LLM-as-judge rubric/threshold evaluation in `src/helio/application/commands/gates.py`; missing or inconclusive evidence cannot pass, and regression checks use the last stable baseline.
- [ ] T055 [US2] Implement atomic bounded paid-token reservations and actual-usage reconciliation in `src/helio/application/commands/quota_ledger.py`, using T043; concurrent branches share one quota and unknown/timed-out usage retains its reservation.
- [ ] T056 [US2] Implement quota exhaustion in `src/helio/application/commands/run_recovery.py`: stop paid dispatch, select only a configured live-probed free-local model with required capabilities and the same gates, else persist `quota_exhausted` checkpoint and enter `pending` with no model calls.
- [ ] T057 [US2] Implement authorized quota increase and same-run restoration in `src/helio/application/commands/run_control.py`; validate session/workspace/checkpoint and quota revision, preserve completed stage results, and record interrupted in-flight calls as new attempts rather than claiming exact mid-call continuation.
- [ ] T058 [US2] Implement run admission and start/control/query commands in `src/helio/application/commands/runs.py`: bind accepted specification/pipeline/source revisions, require an accepted brownfield baseline when relevant, enforce project run permission, snapshot acceptance and provider-policy revisions, and retain mode/approval/override evidence.
- [ ] T059 [US2] Implement authenticated SSE replay with `Last-Event-ID`, stable sequence IDs, snapshot fallback, and AG-UI mapping in `src/helio/adapters/http_api/run_events.py`; a client disconnect must not stop the run.
- [ ] T060 [US2] Implement agent-profile and pipeline list/create/publish endpoints in `src/helio/adapters/http_api/pipelines.py` against the Swagger 2.0 operations and errors.
- [ ] T061 [US2] Implement membership, provider-policy, and transfer-audit endpoints in `src/helio/adapters/http_api/project_access.py`, with 403 for unauthorized actions and no transferred content in responses.
- [ ] T062 [US2] Implement run list/start/get/control/quota endpoints in `src/helio/adapters/http_api/runs.py`, including `pending_reason`, checkpoint summary, paid usage/reservations, and conflict handling for invalid resume.
- [ ] T063 [US2] Implement pipeline editor and run-status HTMX fragments in `src/helio/adapters/dashboard/pipelines.py` and `src/helio/adapters/dashboard/templates/pipelines.html`; show agent activity, attempts, gate evidence, quota/fallback/pending state, and role-permitted controls.
- [ ] T064 [US2] Implement project access and transfer-audit dashboard in `src/helio/adapters/dashboard/access.py` and `src/helio/adapters/dashboard/templates/access.html`; only Owner/Tech Lead can see management controls, and every denial has a readable reason.
- [ ] T065 [P] [US2] Define Open WebUI action inputs/outputs before implementation in `specs/001-helio-agent-platform/contracts/open-webui.md`, then implement bounded A2UI payload validation and Open WebUI API/MCP exposure in `src/helio/adapters/dashboard/a2ui.py` and `src/helio/adapters/http_api/open_webui.py`; unknown components render inertly and all actions retain Helio authorization.
- [ ] T066 [US2] Run T035-T039 with fixture agents and verify [quickstart Scenarios B, F, and G](quickstart.md) in `tests/end_to_end/test_pipeline_controls.py`; include no paid dispatch after quota, local fallback quality gates, checkpoint failure, and denied provider/role cases.

**Checkpoint**: US2 executes a fully observable, bounded pipeline without requiring live paid-model credentials in the test path.

---

## Phase 5: User Story 3 - Prepare an Existing Project for Autonomous Work (Priority: P2)

**Goal**: Reconstruct a source-backed multi-repository baseline, candidate specification, and change history; accept a version automatically only after all required checks pass and no blocking gap remains. Covers FR-001, FR-009 to FR-011, and the brownfield part of FR-021.

**Independent Test**: Import two fixture repositories with a known conflict and history. Inspect evidence and proposed changes without modifying either repository. An inconclusive check blocks acceptance; a new version with passing checks is accepted automatically.

### Tests for User Story 3

- [ ] T067 [P] [US3] Write contract tests for baseline start/get/evaluate and linked specification creation in `tests/contract/test_baseline_api.py`, including immutable versions and blocked results.
- [ ] T068 [P] [US3] Write domain tests for observed/inferred/unverified findings, repository relationship boundaries, conflict retention, check outcomes, and automatic acceptance in `tests/domain/test_baseline.py`.
- [ ] T069 [P] [US3] Write multi-repository reconstruction and human-edit reimport tests in `tests/integration/test_brownfield_reconstruction.py`; assert no source mutation and an autonomous run remains blocked until a new accepted version exists.

### Implementation for User Story 3

- [ ] T070 [P] [US3] Model Repository, RepositoryRelation, and SourceEvidence in `src/helio/domain/projects/repository.py`: related repositories belong to one project; observed code findings require repository ID, revision, path, and location where available; inferred claims are labeled.
- [ ] T071 [P] [US3] Model Baseline, BaselineFinding, and BaselineCheckResult in `src/helio/domain/projects/baseline.py`: versions are immutable; a finding has evidence or is unverified; conflicts retain both sources; a required result is passed/failed/inconclusive; acceptance requires all passed and no blocking finding.
- [ ] T072 [US3] Implement repository intake and revision-set detection in `src/helio/application/commands/repositories.py`; record unavailable or history-free repositories as visible gaps and create a new baseline version when external commits or human edits appear.
- [ ] T073 [P] [US3] Implement local Git file/history/change-log extraction with source locators in `src/helio/adapters/knowledge_graphify/git_source.py`; process each repository independently and never mutate imported refs.
- [ ] T074 [P] [US3] Implement optional Graphify code-map capability checks and extraction in `src/helio/adapters/knowledge_graphify/adapter.py`; classify tool output as observed or inferred and keep Helio's evidence record canonical.
- [ ] T075 [US3] Reconstruct repository relations, interfaces, behavior, dependencies, history, candidate specifications, and change chronology from source evidence in `src/helio/application/commands/baselines.py`; preserve conflicting claims and link candidate specifications to the baseline version.
- [ ] T076 [US3] Evaluate project-defined baseline checks and record an automatic AcceptanceDecision in `src/helio/application/commands/baseline_checks.py`; failed/inconclusive checks or blocking gaps set `blocked`, while all-passing results set `accepted` without human sign-off.
- [ ] T077 [US3] Implement baseline start/get/evaluate endpoints in `src/helio/adapters/http_api/baselines.py`, returning findings, source references, required checks, and acceptance decision by version.
- [ ] T078 [US3] Implement the brownfield evidence and check-result page in `src/helio/adapters/dashboard/baselines.py` and `src/helio/adapters/dashboard/templates/baselines.html`; distinguish observed, inferred, and unverified claims and show why a run is blocked.
- [ ] T079 [US3] Run T067-T069 and [quickstart Scenario C](quickstart.md) in `tests/end_to_end/test_brownfield_baseline.py`; verify accepted old versions remain immutable after a returned human edit and the new version must pass again.

**Checkpoint**: US3 can reconstruct and evaluate a brownfield project without executing a pipeline; US2 run admission consumes the accepted baseline version.

---

## Phase 6: User Story 4 - Compare Execution Strategies (Priority: P3)

**Goal**: Run one accepted specification under separate pipeline strategies, retain exact source/output identity, compare evidence and resource use, and record selection rationale. Covers FR-012 and FR-013.

**Independent Test**: Launch two fixture runs from the same specification and source revision. Verify distinct worktrees/output refs, compare quality/time/model/tokens, then select one result with a recorded reason.

### Tests for User Story 4

- [ ] T080 [US4] Add a contract-first selection operation for a run output and rationale to `specs/001-helio-agent-platform/contracts/openapi.yaml`, then write same-specification comparison and selection tests in `tests/contract/test_comparisons_api.py`; existing comparison response fields remain compatible.
- [ ] T081 [P] [US4] Write two-strategy worktree isolation and comparison tests in `tests/integration/test_strategy_comparison.py`; reject a comparison of unrelated specifications or mixed source revisions without an explicit warning.

### Implementation for User Story 4

- [ ] T082 [P] [US4] Model Workspace and Comparison in `src/helio/domain/execution/comparison.py`: a strategy owns its worktree/output refs and source revision, active isolation refs cannot collide, and a selection retains exact output plus a T011 DecisionRecord reference.
- [ ] T083 [US4] Create and clean up one Git worktree per strategy without deleting evidence in `src/helio/adapters/deployment/worktrees.py`; protect the source repository and reject shared worktree paths.
- [ ] T084 [US4] Launch strategy runs from one immutable specification revision in `src/helio/application/commands/strategies.py`, using T082-T083 and distinct workspace IDs, pipeline versions, and run evidence.
- [ ] T085 [US4] Aggregate passed/failed gates, elapsed time, model IDs, paid/local token use, and decisions; write selected run/output and alternatives/rationale through the shared decision port in `src/helio/application/commands/comparisons.py`.
- [ ] T086 [US4] Implement `/projects/{projectId}/comparisons` and the T080 selection operation in `src/helio/adapters/http_api/comparisons.py`, enforcing project permission and same-specification checks from the source contract.
- [ ] T087 [US4] Render comparison and selection controls in `src/helio/adapters/dashboard/comparisons.py` and `src/helio/adapters/dashboard/templates/comparisons.html`, showing source revisions and distinct evidence for both strategies.
- [ ] T088 [US4] Run T080-T081 and [quickstart Scenario D](quickstart.md) comparison checks in `tests/end_to_end/test_strategy_comparison.py`; demonstrate that no output or worktree is shared.

**Checkpoint**: US4 can compare two completed fixture strategies independently of prototype or deployment work.

---

## Phase 7: User Story 5 - Review Prototypes and Deployment Environments (Priority: P3)

**Goal**: Review static prototypes with mocks in collision-free local stacks and validate Local, Dev, Pre, and Pro configurations for macOS, WSL2, or AWS before a deployment decision. Covers FR-014 to FR-016.

**Independent Test**: Open two fixture prototypes concurrently on distinct Compose project names/host ports, inspect mock health, configure four environments, and see missing prerequisites plus an AWS change set before any update.

### Tests for User Story 5

- [ ] T089 [P] [US5] Write prototype, review-environment, environment CRUD/validation, and deployment-proposal API contract tests in `tests/contract/test_review_environments_api.py`.
- [ ] T090 [P] [US5] Write domain tests for Local/Dev/Pre/Pro and macOS/WSL2/AWS target enums, immutable environment revisions, prerequisite failure/unknown blocking, and review-stack name/port uniqueness in `tests/domain/test_environments.py`.
- [ ] T091 [P] [US5] Write concurrent mock/prototype stack and missing-target-prerequisite tests in `tests/integration/test_review_stacks.py`, including a non-applying AWS change-set fixture.

### Implementation for User Story 5

- [ ] T092 [P] [US5] Model Prototype, MockService, and ReviewEnvironment in `src/helio/domain/environments/review.py`: prototype points to an immutable run output; active Compose project names and published host ports are unique on one local host.
- [ ] T093 [P] [US5] Model Environment, EnvironmentCheck, and DeploymentRecord in `src/helio/domain/environments/model.py`: names are Local/Dev/Pre/Pro, targets are macOS/WSL2/AWS, changes create revisions, and failed or unknown required checks block deployment actions.
- [ ] T094 [US5] Build prototype and mock artifact references from a completed run in `src/helio/application/commands/prototypes.py`; reject missing immutable run output or mock contract/fixture refs.
- [ ] T095 [US5] Allocate a unique Compose project name and host ports, then start/inspect/stop a prototype-plus-mocks review stack in `src/helio/adapters/deployment/review_compose.py`; keep each stack's internal DNS and resources isolated.
- [ ] T096 [US5] Define revisioned target configuration and validate required service/resource/secret references in `src/helio/application/commands/environments.py`; return each prerequisite's passed/failed/unknown state and evidence.
- [ ] T097 [P] [US5] Validate Docker Desktop, Compose, certificates, and port availability for local macOS and Windows WSL2 in `src/helio/adapters/deployment/local_targets.py`; do not claim readiness when a required prerequisite is unknown.
- [ ] T098 [P] [US5] Generate parameterized CloudFormation templates and inspect change-set replacements/deletes for AWS in `deploy/aws/template.yaml` and `src/helio/adapters/deployment/aws_target.py`; keep apply separate from validation/proposal.
- [ ] T099 [US5] Create a deployment proposal only for a validated environment revision and source run in `src/helio/application/commands/deployments.py`; retain change-set and approval references without applying an unreviewed AWS update.
- [ ] T100 [US5] Implement prototype/get/review-stack, environment list/define/validate, and deployment-proposal endpoints in `src/helio/adapters/http_api/environments.py` against the source contract.
- [ ] T101 [US5] Implement prototype/mock health and four-environment dashboard pages in `src/helio/adapters/dashboard/environments.py` and `src/helio/adapters/dashboard/templates/environments.html`; show missing prerequisites and AWS change-set evidence before a release decision.
- [ ] T102 [US5] Run T089-T091 and [quickstart Scenarios D and E](quickstart.md) review/deployment checks in `tests/end_to_end/test_prototype_environments.py`; verify two stacks coexist and no blocked deployment action applies.

**Checkpoint**: US5 supports local visual review and target validation without requiring production cloud deployment.

---

## Phase 8: User Story 6 - Inspect Project Knowledge and Agent Evidence (Priority: P3)

**Goal**: Retrieve decisions, recurring problems, resolutions, tasks, verification, model/token/time evidence, and source-linked exports from a project workspace. Covers FR-017 to FR-019 and evidence parts of FR-020 to FR-021.

**Independent Test**: Complete a fixture run with a failed attempt, record a decision and resolution, retrieve them with source refs and usage, then export one stable task ID to Markdown and a configured issue tracker.

### Tests for User Story 6

- [ ] T103 [P] [US6] Write decision, knowledge search/create, task list/create/export, and run-evidence contract tests in `tests/contract/test_knowledge_api.py`.
- [ ] T104 [P] [US6] Write domain tests for decision alternatives/rationale, source-backed knowledge, superseding corrections, stable task IDs, and observed/estimated/unknown usage in `tests/domain/test_knowledge.py`.
- [ ] T105 [P] [US6] Write telemetry-outage, redacted trace, Markdown export, and tracker-link preservation tests in `tests/integration/test_knowledge_evidence.py` using fake OpenKB and issue adapters.

### Implementation for User Story 6

- [ ] T106 [P] [US6] Model KnowledgeEntry in `src/helio/domain/knowledge/model.py` and reuse T011 DecisionRecord: keep source and affected refs, and link every correction to its superseded entry.
- [ ] T107 [P] [US6] Model TaskRecord in `src/helio/domain/knowledge/tasks.py`: Markdown and issue representations retain one stable project/specification task ID, status, owner, and evidence refs.
- [ ] T108 [US6] Implement architecture-decision recording and source-backed problem/resolution retrieval in `src/helio/application/commands/knowledge.py`; keep prior revisions, source links, and rejected alternatives visible to later agents.
- [ ] T109 [US6] Implement task create/list/export orchestration in `src/helio/application/commands/tasks.py`; preserve project/specification ID and idempotent export receipt, and record unsupported/unconfigured tracker status without losing the Markdown task.
- [ ] T110 [P] [US6] Write project tasks as English Markdown with stable IDs and evidence links in `src/helio/adapters/knowledge_openkb/markdown_tasks.py`.
- [ ] T111 [P] [US6] Implement GitHub and GitLab issue-export adapters behind a task port in `src/helio/adapters/knowledge_openkb/issue_trackers.py`; apply project provider approval and task data scope before export, use configured credentials, retain remote issue refs, and avoid duplicate issues on retry.
- [ ] T112 [P] [US6] Implement optional OpenKB indexing/query adapter in `src/helio/adapters/knowledge_openkb/adapter.py`; apply the same provider/data-scope gate for nonlocal transport, keep Helio records canonical, and return source references rather than uncited generated answers.
- [ ] T113 [US6] Emit project/specification/run/stage/task/model/gate OpenTelemetry spans to Langfuse in `src/helio/adapters/telemetry/traces.py`; redact project content by default, apply provider approval before export, flush workers, and keep local usage/evidence authoritative during sink outage.
- [ ] T114 [US6] Implement decision, task, export, and knowledge endpoints in `src/helio/adapters/http_api/knowledge.py` with project-role checks and the Swagger 2.0 response shapes.
- [ ] T115 [US6] Implement decisions, problems, resolutions, tasks, run traces, and verification evidence pages in `src/helio/adapters/dashboard/knowledge.py` and `src/helio/adapters/dashboard/templates/knowledge.html`; show missing/unknown token usage explicitly.
- [ ] T116 [US6] Run T103-T105 and [quickstart Scenario E](quickstart.md) knowledge checks in `tests/end_to_end/test_knowledge_handoff.py`; confirm earlier failure evidence, source links, task identity, and local evidence survive telemetry/export outages.

**Checkpoint**: US6 makes the accumulated project record usable by people and later agent tasks without depending on a remote trace sink.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Validate complete behavior, documentation, contract compatibility, and local handoff after the requested stories are integrated.

- [ ] T117 [P] Run the full generated-client and source-contract runtime drift check across all implemented Swagger operations and document any incompatible API migration in `scripts/check_contract.py` and `docs/helio/api-migration.md`; public contract changes require an impact record.
- [ ] T118 [P] Verify that every accepted run has criterion, gate result, independent verifier evidence, and no known failing regression in `tests/end_to_end/test_regression_evidence.py`; include failed, inconclusive, and override paths.
- [ ] T119 [P] Verify guided install, Compose startup, API/dashboard response, state-owner connectivity, and non-destructive teardown on macOS and WSL2 fixtures in `tests/end_to_end/test_local_install.py`.
- [ ] T120 [P] Verify cross-project isolation, least-privilege agent grants, outbound transfer redaction, and denial logging in `tests/integration/test_policy_redaction.py`.
- [ ] T121 Write English architecture/ports, local operation, recovery, corporate CA/JFrog, local model eligibility, and AWS validation guidance in `docs/helio/architecture.md` and `docs/helio/operations.md`; document public-interface impact and migration where relevant.
- [ ] T122 Execute all seven scenarios in `specs/001-helio-agent-platform/quickstart.md` through `make verify` and record pass/fail evidence and remaining environment-only prerequisites in `docs/helio/validation.md`; do not claim live-provider or AWS checks passed without credentials and a target.

**Checkpoint**: The contract, local setup, regression evidence, and handoff documentation are reviewable before publication.

---

## Analysis Remediation Tasks (Cross-Phase Prerequisites)

**Execution rule**: These IDs were appended after analysis to preserve existing task and GitHub issue identities. Run each task before the earlier IDs it blocks, regardless of its position in this file. T123 is the first implementation gate; T136-T137 are release-validation gates. Existing task IDs do not change.

- [ ] T123 After design tasks T124, T127, and T135 and before T001, have the Product Owner and Tech Lead record feature acceptance criteria, affected source contracts, deterministic and judge quality checks, and any architecture choice with rationale and rejected alternatives in `docs/helio/implementation-readiness.md`; link the record to `specs/001-helio-agent-platform/spec.md` and `contracts/`, mark missing decisions as unresolved, and do not start implementation until both roles have reviewed the evidence. Addresses the constitution pre-implementation gate.
- [ ] T124 Before T015-T016, define a local first-operator bootstrap and authenticated session/token lifecycle in `specs/001-helio-agent-platform/spec.md`, `specs/001-helio-agent-platform/contracts/openapi.yaml`, and `docs/helio/auth-bootstrap.md`: one-time installer setup, no shared default credential, secret-backed tokens, revocation/recovery, audit, and project-scoped Owner/Tech Lead role assignment. Keep external identity providers optional and document the contract impact.
- [ ] T125 Before T126, write first-operator, token expiration/revocation, recovery, unauthenticated request, and project-role isolation tests in `tests/integration/test_auth_bootstrap.py`; prove that fixture identities are not the production bootstrap path and that a new installation can reach an authenticated dashboard.
- [ ] T126 After T006-T007 and T124-T125, implement the guided local operator bootstrap and secret-backed session/token validation in `scripts/install.py` and `src/helio/adapters/identity_and_secrets/bootstrap.py`; wire T015-T016 to the resulting identity port without creating a global bypass. T126 blocks completion of T015-T016 and T021.
- [ ] T127 Before T044, T048, and T065, define project-configurable data-category classification, source/object labels, task-minimum category scope, unknown-category denial, and the Open WebUI action transport boundary in `specs/001-helio-agent-platform/contracts/agent-runtime.md` and `specs/001-helio-agent-platform/contracts/open-webui.md`; update `specs/001-helio-agent-platform/spec.md` and the Swagger 2.0 contract for any new public fields. Do not invent a mandatory universal category list.
- [ ] T128 Before T129, write data-scope tests in `tests/integration/test_data_scope.py` for unclassified data, task scope wider than needed, revoked or unapproved providers, Open WebUI-initiated dispatch, and telemetry export; assert every allow/deny decision precedes transport and audits contain no payload or credentials.
- [ ] T129 After T127-T128, implement source/object classification and task-minimum scope validation in `src/helio/application/commands/data_scope.py`; require T048 egress and T065 Open WebUI actions to use it before any nonlocal transfer, with policy revision and decision evidence. T129 blocks completion of T048, T065, T066, and T120.
- [ ] T130 Before T131, write failure-diagnosis tests in `tests/integration/test_failure_diagnosis.py` for deterministic and judge failures, comparison with the last stable source/behavior state, absent initial baseline, recorded cause/evidence, bounded retry, and reasoning/model escalation; a retry without diagnosis must fail.
- [ ] T131 After T130, implement a recorded failure-diagnosis decision in `src/helio/application/commands/failure_diagnosis.py`, including changed inputs since the last stable state or an explicit no-baseline finding; require T053-T054 to call it before retry or escalation and retain model, context sources, token/time, and verifier evidence. T131 blocks completion of T053-T054, T066, and T118.
- [ ] T132 Before T133, write a new-task retrieval test in `tests/integration/test_resolution_context.py`: a related prior resolution is returned with project and source references, unrelated projects are excluded, and a clean-context execution agent receives only bounded relevant material while its independent verifier starts clean.
- [ ] T133 After T049, T053, T108, and T132, add project-scoped prior-resolution lookup and bounded context injection at agent task start in `src/helio/application/commands/run_engine.py` and `src/helio/application/commands/knowledge.py`; route injected content through T048 egress admission for external providers, record selected source refs and retrieval failures, and keep verification context independent. T133 blocks completion of T116, T118, and T122.
- [ ] T134 After T008 and before T021, add tests and explicit `source`, `foundation`, and `full` contract-check modes in `tests/contract/test_contract_check_modes.py`, `scripts/check_contract.py`, and `Makefile`: source mode validates Swagger and client generation without a running API, foundation mode exercises only implemented operations, and full mode exercises every operation at T117. Fail when a mode silently skips an operation it claims to cover.
- [ ] T135 Before T080-T084, align US4 wording in `specs/001-helio-agent-platform/spec.md`, `specs/001-helio-agent-platform/plan.md`, and affected task/contract text so strategy comparison requires an **accepted specification revision** under normal or automatic acceptance rules; reserve **approved** for provider-policy and human approval decisions. Review cross-artifact terms without changing the acceptance policy.
- [ ] T136 [P] After T119, run the guided install, Compose startup, API/dashboard, state-owner connectivity, and non-destructive teardown on an actual supported macOS host; capture host/tool versions, commands, results, and unresolved prerequisites in `docs/helio/validation-macos.md`. Fixture tests alone cannot complete this task.
- [ ] T137 [P] After T119, run the same guided install and Compose smoke path on an actual Windows WSL2 host; capture host/tool versions, commands, results, and unresolved prerequisites in `docs/helio/validation-wsl2.md`. Fixture tests alone cannot complete this task.

**Checkpoint**: T123-T135 close the specification-analysis gaps before their blocked work is accepted. T136-T137 must pass before T122 claims verified support on both local targets; unavailable hosts stay explicit release blockers, not assumed passes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Pre-implementation gate**: Complete design tasks T124, T127, and T135 before T123; T123 must pass before T001. T125-T126 complete the local identity path before T015-T016 and T021.
- **Setup (Phase 1)**: Starts after T123. T001-T002 establish paths and dependencies; T003-T008 follow where their inputs require them.
- **Foundational (Phase 2)**: Depends on setup. T009-T010 define checks; T011-T012 define common types and ports; T013-T020 provide persistence, access, API, UI, and fixtures; T134 defines contract-check modes before T021 proves the foundation. All user stories depend on this checkpoint.
- **US1 (Phase 3, P1)**: Starts after foundation. T025-T027 are independent models; T028-T030 compose them; T031-T033 expose the behavior; T034 validates the increment. This is the MVP.
- **US2 (Phase 4, P2)**: Starts after foundation and uses an accepted US1 specification for live run admission. T127-T129 define and enforce data scope before T044/T048/T065. T130-T131 establish diagnosis before T053-T054. T040-T044 and T049 are independent model/port work. T045-T048, T050-T052, and T053-T058 form catalog, policy, runtime, gate, and quota layers. T059-T065 expose them; T066 validates the increment.
- **US3 (Phase 5, P2)**: Repository extraction and baseline evaluation can proceed beside US2 after foundation and the project entity from T025. T070-T071 precede T072-T076; T077-T079 follow. Its own baseline acceptance test uses prepared repositories; full autonomous-run admission also needs T058.
- **US4 (Phase 6, P3)**: T135 normalizes accepted-specification wording before T080-T084. It needs US2 run/workspace results and an accepted US1 specification; T082-T085 precede T086-T088.
- **US5 (Phase 7, P3)**: Can start after US2 supplies a completed run. T092-T099 precede T100-T102; the two-strategy quickstart comparison also needs US4.
- **US6 (Phase 8, P3)**: Knowledge models and CRUD can start after foundation. Run-trace and task-evidence integration needs US2; T106-T113 precede T114-T116. T132-T133 add prior-resolution context before T116.
- **Polish (Phase 9)**: T117-T122 follow the stories they validate. T122 runs after all requested story checkpoints and actual-host evidence T136-T137; missing host evidence blocks a verified local-platform claim.

### User Story Dependencies

| Story | Required earlier result | Independent proof |
| --- | --- | --- |
| US1 | Foundation | Greenfield interview, specification acceptance, and two roadmaps without agents. |
| US2 | Foundation; accepted US1 fixture specification for run admission | Fixture pipeline, gates, access/egress, quota fallback, and resume. |
| US3 | Foundation; project fixture or T025 | Multi-repository baseline and automatic checks without source mutation; run admission integration after T058. |
| US4 | US1 accepted specification and US2 completed fixture runs | Isolated worktrees, comparison, and selection. |
| US5 | US2 completed fixture run; US4 only for two-strategy comparison | Prototype/mocks and target validation, with no cloud apply. |
| US6 | Foundation for CRUD; US2 for run evidence | Source-linked decision/task retrieval and exports with local evidence retained. |

### Within Each User Story

1. Write its contract/domain/integration checks first; confirm they fail for missing behavior.
2. Add domain models and validation before application commands.
3. Add adapters and endpoints only after their ports and commands are stable.
4. Run the story's independent fixture scenario before treating the checkpoint as complete.
5. Keep public contract impact, migration evidence for incompatible changes, and failed attempts in the project record.

### Parallel Opportunities

- After T011-T012, state-owner work (T013-T014), authorization (T015-T016), secret resolution (T017), and dashboard base (T019) can be assigned to separate owners; their integration waits for T021.
- US2 and US3 domain/extraction work can overlap once project identity is available. US4, US5, and US6 can overlap after their stated inputs exist.
- Parallel model and fixture tasks in a story write different files. Tasks touching the same command, route, or evidence path stay sequential.

## Parallel Examples by User Story

| Story | Parallel batch after its prerequisites | Join before |
| --- | --- | --- |
| US1 | T022/T023/T024 tests; T025/T026/T027 models | T028-T030 application commands |
| US2 | T035-T039 tests; T040-T044 models; T050/T051/T052 adapters after T049 port | T053-T058 orchestration and T066 validation |
| US3 | T067/T068/T069 tests; T070/T071 models; T073/T074 extractors | T075-T076 baseline decision |
| US4 | T080/T081 tests | T084-T085 strategy comparison after workspace model/adapter |
| US5 | T089/T090/T091 tests; T092/T093 models; T097/T098 target adapters | T099 deployment proposal and T102 validation |
| US6 | T103/T104/T105 tests; T106/T107 models; T110/T111/T112 export/index adapters | T113-T116 evidence integration |

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete design T124/T127/T135 and readiness T123, then setup T001-T008, identity tests/implementation T125-T126, contract modes T134, and foundation T009-T021 in dependency order.
2. Complete US1 T022-T034 with fixture identities; validate normal and automatic acceptance and both roadmap views.
3. Stop at the US1 checkpoint to demonstrate a usable intake workflow without agent execution.

### Incremental Delivery

1. Add US2 pipelines and project access/quota controls; keep fixture agents as the deterministic verification path.
2. Add US3 baseline reconstruction; connect its accepted version to US2 run admission.
3. Add US4 isolated comparison, US5 prototype/environment review, and US6 knowledge/evidence retrieval as their inputs become available.
4. Finish T117-T122 only after the requested story checkpoints and applicable remediation tasks pass. T136-T137 require actual hosts before claiming both local targets are verified. Numeric schedule and model-cost estimates require measured task timings, selected models, and budgets; this task list does not invent them.

### Parallel Team Strategy

The stated senior full-time squad has a Product Owner, Tech Lead, two Backend engineers, DevOps engineer, and Frontend/UX/QA engineer. The Product Owner and Tech Lead supply acceptance and architecture decisions while backend work splits between domain/application and adapters. DevOps can own setup, local stacks, model/runtime probes, and targets; Frontend/UX/QA can own HTMX views and fixture journeys after ports and source contracts are fixed. Parallel work must use separate files and the dependencies above.

## Notes

- Every `[P]` marker applies only after the dependencies named above are complete; it never authorizes concurrent edits to one file.
- Project and task records keep immutable versions, source evidence, and UTC event times. A denied transfer or failed check is retained rather than overwritten.
- Optional external integrations and heavy local models are validated when configured; deterministic fixture paths must remain runnable without their credentials or model artifacts.
- Use English for code and stored reports, ASD-STE100 Simplified Technical English for documentation, and Spanish for user-facing messages. Before publication, review public API compatibility and run relevant local startup/connectivity checks.
