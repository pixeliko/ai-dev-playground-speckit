# Research: Helio Agent Platform

**Date**: 2026-09-23
**Inputs**: [spec.md](spec.md), [constitution](../../.specify/memory/constitution.md).
**Status**: Phase 0 complete. The decisions below resolve planning choices. External
credentials, model artifacts, and capacity remain deployment inputs, not hidden assumptions.

## R1. Product shape and domain boundaries

**Decision**: Start with a modular control plane in Python 3.13+. Keep intake, project
reconstruction, agent catalog, pipeline execution, evidence, knowledge, and environment
configuration as domain modules with ports and adapters. Host the first local deployment in
one API process and one isolated worker process. Design contracts before adapters.

**Rationale**: This keeps domain rules replaceable and supports later human or agent
ownership. A small initial runtime also gives DuckDB one clear write owner.

**Alternatives considered**: Separate microservices for every module would increase
deployment and contract work before boundaries have been tested. A single unstructured
application would make later extraction and brownfield handoff harder.

## R2. HTTP API and HTMX dashboard

**Decision**: Use a hand-authored machine API contract. Implement it with a FastAPI HTTP
adapter. Serve dashboard pages and HTMX fragments from distinct routes. Use semantic CSS
tokens to follow the ShadCN visual style without React components. Use the supplied brand
assets as the visual reference.

**Rationale**: HTMX expects server HTML and the machine API needs a stable schema. Distinct
routes prevent HTML fragments from changing JSON contracts. FastAPI can serve HTML and API
routes. ShadCN documents reusable theme tokens. [FastAPI](https://fastapi.tiangolo.com/),
[HTMX](https://htmx.org/docs/),
[ShadCN theming](https://ui.shadcn.com/docs/theming/).

**Alternatives considered**: React ShadCN components conflict with the explicit HTMX
decision. A single endpoint that switches on `HX-Request` can work but needs `Vary:
HX-Request` and more cache and contract tests. A client-only dashboard adds another runtime.

## R3. API contract generator

**Decision**: Keep the exact `swaggerapi/swagger-generator` service as the required
generation check. Author a Swagger 2.0 source contract for its legacy service and generate
a test client from that source. Pin the image digest during implementation. Do not make
generated Python server code the source of truth.

**Rationale**: The named image is the Swagger Codegen web service. Its V3 service is
published as a separate image, and V3 supports OpenAPI 3.0.x but has no documented FastAPI
server target. FastAPI emits OpenAPI 3.1 by default, so contract tests must compare
implemented behavior with the Swagger 2.0 source rather than treating FastAPI output
as the source of truth. The contract can be checked without coupling the domain to
generated code. [FastAPI OpenAPI](https://fastapi.tiangolo.com/how-to/extending-openapi/).
[Named image](https://hub.docker.com/r/swaggerapi/swagger-generator/),
[V3 service](https://swagger.io/docs/open-source-tools/swagger-codegen/codegen-v3/online-generators/),
[compatibility](https://swagger.io/docs/open-source-tools/swagger-codegen/codegen-v3/compatibility/).

**Alternatives considered**: Moving immediately to `swagger-generator-v3` changes the
agreed image. Generating the server implementation would make the generator target a
domain dependency. If the pinned legacy image cannot validate the required contract,
the Tech Lead must record an amendment or an explicit exception before implementation.

## R4. Operational data and DuckDB

**Decision**: Put mutable operational state behind one persistence port and one owner
process per DuckDB file. Workers submit state changes to that owner; they do not write
the database file directly. Export snapshots and run evidence for recovery. Do not use
DuckDB as a shared file written by several containers.

**Rationale**: DuckDB documents read/write use by one process, with concurrent writer
threads within that process. This is feasible for the initial control plane but sets a
clear scaling limit. [DuckDB concurrency](https://duckdb.org/docs/current/connect/concurrency).

**Alternatives considered**: A shared DuckDB volume across writer containers violates
the documented native concurrency model. Adding a second database now would change the
agreed baseline without a demonstrated need.

## R5. Pipeline execution and protocols

**Decision**: Keep pipeline scheduling and gates in Helio. Model a run as an append-only
stage/event history with a materialized current state. Expose run events to the dashboard
through an AG-UI adapter. Treat A2UI payloads as optional declarative views rendered only
from an approved component catalog. Integrate Open WebUI through documented OpenAPI/MCP
or narrow Functions, not by placing orchestration inside its plugin process.

**Rationale**: AG-UI defines lifecycle and agent events; A2UI defines UI payloads. Open
WebUI plugins run with server privileges, and its older Pipelines path is deprecated.
[AG-UI events](https://docs.ag-ui.com/concepts/events),
[A2UI](https://a2ui.org/),
[Open WebUI extensions](https://docs.openwebui.com/features/extensibility/).

**Alternatives considered**: Using Open WebUI as the pipeline scheduler would bind core
run state to its extension lifecycle. Assuming native A2UI support in HTMX or Open WebUI
would be unverified. The first delivery can show server-rendered run state while the
protocol adapters are validated against fixtures.

## R6. Agent harnesses and triage

**Decision**: Use an agent-runtime port with one adapter per harness. For Pi, use its
documented JSONL RPC mode in an isolated process or container and wait for terminal run
events rather than only command acknowledgement. Keep Devin authentication and API use in
a separate adapter. Use decidr only for bounded option selection, with calibration evidence
or deterministic fallback before a confidence threshold controls a gate.

**Rationale**: Pi RPC exposes process and run events. Pi does not itself provide a general
security sandbox. Devin tokens and API permissions are separate from Pi. decidr's raw
confidence is not automatically calibrated and may leave options unscored.
[Pi RPC](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/rpc.md),
[Pi containerization](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/containerization.md),
[Devin authentication](https://docs.devin.ai/api-reference/authentication),
[decidr](https://github.com/devanmolsharma/decidr).

**Alternatives considered**: One adapter that assumes a shared token or event format for
Pi and Devin is not supported by their documented interfaces. Treating decidr as a general
orchestrator would exceed its closed-choice function.

## R7. Quality gates and progressive effort

**Decision**: Store gate type, fixture, expected evidence, threshold, and acceptance state
before a run. Prefer deterministic checks for behavior and contracts. Allow evaluator
judgments only when a project records a rubric and threshold. Start each execution and
verification attempt with separate scoped context. Escalation changes one recorded variable
at a time: context, time, or model capability.

**Rationale**: This applies the constitution without inventing global thresholds. It lets
the dashboard compare the effect and cost of each retry.

**Alternatives considered**: A single pass/fail field cannot explain a failure or support
safe retries. A global numeric judge threshold has no stakeholder approval or test basis.

## R8. Brownfield reconstruction and living knowledge

**Decision**: Build the baseline from repository files, Git history, change logs, specs,
and explicit user documents. Attach a source reference and confidence class to each
finding. Evaluate each version against project-defined checks and accept it automatically
only when every required check passes and no blocking gap remains. Use Graphify as an
optional local code-map adapter and OpenKB as an optional project knowledge adapter.
The canonical decision and evidence records remain in Helio and can be exported.

**Rationale**: Graphify labels extracted versus inferred relationships. OpenKB indexes
documents and supports queries. Neither source proves it can replace baseline checks or
serve as Helio's canonical transactional store.
[Graphify](https://github.com/Graphify-Labs/graphify),
[OpenKB](https://github.com/VectifyAI/OpenKB).

**Alternatives considered**: Regenerating specs directly from an LLM answer without source
citations risks invented architecture. Making an optional knowledge tool the only record
would make project handoff depend on that tool.

## R9. Isolated workspaces and prototype review

**Decision**: Record a source revision for each run and create one Git worktree per strategy.
Give each prototype review its own Compose project name, internal service DNS, and assigned
host ports. Preserve the selected result and comparison record before handoff.

**Rationale**: Worktrees isolate changes while sharing repository history. Compose uses
project-scoped networks and service names, so a unique project name and host port plan
avoid collisions. [Git worktree](https://git-scm.com/docs/git-worktree),
[Compose networking](https://docs.docker.com/compose/how-tos/networking/).

**Alternatives considered**: Reusing one worktree would mix strategy outputs. Fixed host
ports for every review run would collide on the same machine.

## R10. Environments and cloud deployment

**Decision**: Define Local, Dev, Pre, and Pro as environment records with target-specific
settings and validation. Use Compose profiles and project names for local macOS and WSL2.
Model AWS target resources with CloudFormation templates and parameter sets. Require a
change-set review before an AWS update. Do not choose a production compute or storage
topology until capacity and availability needs are measured.

**Rationale**: CloudFormation parameters support environment differences; change sets
expose replacements and deletes. Docker Desktop supports Compose and WSL2 integration.
[Compose project names](https://docs.docker.com/compose/how-tos/project-name/),
[WSL2 integration](https://docs.docker.com/desktop/features/wsl/),
[CloudFormation parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html),
[change sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html).

**Alternatives considered**: Treating Compose files as a direct AWS deployment template
does not define cloud resources. Choosing a multi-node topology now would invent
requirements and conflict with DuckDB's initial single-writer design.

## R11. Traces, tokens, and elapsed time

**Decision**: Emit OpenTelemetry spans for project, specification, run, stage, task, model
call, and gate. Use Langfuse as the trace and evaluation sink. Keep a local run summary
with model ID, token counts, elapsed time, outcome, and trace ID; flush short-lived workers
before exit.

**Rationale**: Langfuse's Python SDK is based on OpenTelemetry and models nested
generations. The local summary remains available if the trace sink is unavailable.
[Langfuse SDK](https://langfuse.com/docs/observability/sdk/overview),
[Langfuse data model](https://langfuse.com/docs/observability/data-model),
[OpenTelemetry Python](https://opentelemetry.io/docs/languages/python/instrumentation/).

**Alternatives considered**: Only sending remote traces would hide evidence when the
collector is down. A custom trace protocol would duplicate the chosen observability stack.

## R12. Corporate artifacts and certificates

**Decision**: The installer validates the corporate CA and configured artifact endpoints.
Use JFrog CLI authentication and its npm integration where documented. Configure uv with
its JFrog index credentials and CA settings. Configure Hugging Face access through its
documented token or an organization-provided proxy. Never store raw tokens in project
records. The installer reports unavailable integrations instead of guessing credentials.

**Rationale**: JFrog CLI does not document a generic `uv` or Hugging Face wrapper command.
uv documents a JFrog index flow; Hugging Face documents its own token flow.
[JFrog CLI](https://docs.jfrog.com/integrations/docs/jfrog-cli-command-reference),
[uv with JFrog](https://docs.astral.sh/uv/guides/integration/jfrog/),
[uv certificates](https://docs.astral.sh/uv/concepts/authentication/certificates/),
[Hugging Face authentication](https://huggingface.co/docs/huggingface_hub/main/en/quick-start).

**Alternatives considered**: Passing one JFrog CLI token blindly to all tools lacks
documented support and risks failed authentication. Bundling a corporate CA or user token
into an image would expose secrets.

## R13. Local model capability registry

**Decision**: Store each model's provider/runtime, ID, revision, checksum, license,
hardware need, capability probe, and fallback. Validate availability during installation.
Use Ollama where a model and required capability work there; allow another runtime for
models with different formats. Make heavy or unverified models optional local profiles,
not prerequisites for starting the control plane.

**Rationale**: The named assets do not share one verified Ollama runtime. Needle 3 uses
a `.cact` format and its own runtime. Nemotron-3-Embed-8B-BF16 is distributed for
Transformers/Sentence Transformers. Qwen3-TTS and VibeVoice need runtime and provenance
validation before installer support. [Needle 3](https://huggingface.co/Cactus-Compute/needle3),
[Nemotron model files](https://huggingface.co/nvidia/Nemotron-3-Embed-8B-BF16/tree/main),
[Qwen3-TTS community package](https://ollama.com/jstzwhc/Qwen3-TTS),
[VibeVoice repository](https://github.com/microsoft/VibeVoice).

**Alternatives considered**: An unconditional `ollama pull` for every named asset would
fail for unsupported formats or hardware. Silently replacing a named model would erase
a stakeholder constraint.

## R14. Roadmap estimates

**Decision**: Produce two dependency-based roadmaps from the same story graph. The human
view uses the stated six-person squad and explicit blocking roles. The agent view uses
stage counts, measured task duration, model effort, retries, judge calls, and a user-set
paid-model token quota. It models local fallback and time spent pending separately.
Show formulas and scenario ranges only after calibration runs.
Use no universal schedule or cost figure in this plan.

**Rationale**: No measured throughput, failure rate, model prices, or budget is available
for a credible numeric estimate. The system can still expose the inputs and critical path.

**Alternatives considered**: A fixed calendar promise or token-cost total would be
invented. Ignoring parallel and blocking stages would hide the main planning risk.


## R15. Project permissions and external data transfer

**Decision**: Store project memberships with Owner, Tech Lead, runner, and viewer
permissions. Give agents task-scoped grants with expiry and a project boundary.
An application authorization port checks both identity and project membership on
each action. Before any outbound transfer of project data, a local egress policy
checks the project's approved provider set and the task's declared data categories.
It records allow or deny metadata synchronously before dispatch. The log stores
destination, purpose, category, policy version, time, request ID, and coarse size,
not content or credentials. Exported traces omit prompt and source content by
default and pass the same provider approval check.

**Rationale**: The clarification makes permissions and provider approval project
specific. FastAPI dependencies can enforce runtime membership; broad OAuth scopes
alone do not express a project's current membership. OpenTelemetry warns that
generative AI message attributes may contain sensitive content. Langfuse masking
protects its own export path but is not a substitute for local admission and audit.
[FastAPI dependencies](https://fastapi.tiangolo.com/tutorial/dependencies/),
[OpenTelemetry sensitive data](https://opentelemetry.io/docs/security/handling-sensitive-data/),
[Langfuse masking](https://langfuse.com/docs/observability/features/masking).

**Alternatives considered**: Workspace-wide administrator permissions would give
more access than requested. Logging full prompts would conflict with the rule to
record transfers without duplicating their content. A remote trace sink can be
unavailable or batched, so it cannot be the only audit record.

## R16. Specification and baseline acceptance

**Decision**: Use one acceptance record with subject revision, mode, required
checks, result, evidence, timestamp, and human actor when applicable. Normal-mode
specifications require Project Owner or Tech Lead approval. Autonomous and sandbox
specifications may be accepted automatically only after all project-defined checks
pass. Brownfield baselines are accepted automatically after all their required
checks pass and no blocking finding remains. Failed or inconclusive results block
runs. Accepted revisions are immutable; new findings or answers create a new
revision and new acceptance decision.

**Rationale**: This encodes the clarification without confusing human approval
with automatic acceptance. It provides one auditable gate for run admission and
keeps the specification, baseline, and run bound to exact revisions.

**Alternatives considered**: A mandatory human baseline approval contradicts the
chosen autonomous rule. A single boolean approval field cannot show mode, actor,
failed check, or why a run was blocked.

## R17. Paid-token quota, local fallback, and resume

**Decision**: The control plane owns a durable, per-run paid-token quota ledger.
Before each paid request it reserves a bounded input and output allowance in the
single DuckDB write-owner process; parallel branches compete for the same quota.
After a response it reconciles actual usage and releases unused reservation.
Unknown or timed-out usage keeps its reservation until reconciled. At the limit,
the stage stops paid calls. It may switch only to a free local model configured in
the launched workflow whose live capability probe matches the stage. The same
quality gate still applies. If no eligible model is available, the run enters
`pending` with reason `quota_exhausted` and a durable checkpoint. A Project Owner
or Tech Lead can raise the quota, after which the same run resumes from the last
committed stage and session state. Completed stages are not repeated. Any uncertain
in-flight side effect is reconciled through its recorded idempotency key or receipt
before a retry. Resume continues the same task; later independent verification starts
with a clean scoped context.

**Rationale**: Provider usage can arrive after a call, while Langfuse cost and
token traces are asynchronous. The local quota ledger is the admission source.
Ollama's model list shows presence, not tool or audio capability, so fallback needs
a bounded live probe. Pi can reopen a persisted JSONL session and change model,
but `--no-session` cannot resume and its documentation does not promise resuming
an interrupted model call mid-generation. The checkpoint therefore represents
a stable logical session, not an opaque provider call in progress.
[DuckDB transactions](https://duckdb.org/docs/stable/sql/statements/transactions.html),
[Ollama model list](https://docs.ollama.com/api/tags),
[Ollama generation](https://docs.ollama.com/api/generate),
[Pi sessions](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/sessions.md),
[Pi RPC commands](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/rpc-commands.md),
[Langfuse usage](https://langfuse.com/docs/observability/features/token-and-cost-tracking).

**Alternatives considered**: Checking only completed usage allows parallel calls
to overspend the quota. Treating a listed local model as eligible can choose one
that lacks the stage's required capability. Restarting completed stages loses work.
A generic `--no-session` Pi process cannot meet the resume requirement.

**Limit**: A provider may report final usage late or not at all. Reservations
prevent new paid calls beyond the admitted allowance; they do not prove an external
provider's final invoice is equal to the local ledger. This must be shown as
observed or unknown usage in the dashboard. An adapter with unbounded server-side
retrieval or tool expansion is ineligible near the strict quota unless it can bound
every billable token category. [Gemini token accounting](https://ai.google.dev/gemini-api/docs/tokens).
