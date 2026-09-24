# Agent Runtime Port

**Applies to**: FR-005 to FR-008, FR-018, FR-020 to FR-025.
The Helio orchestrator calls a harness through this port. Each harness adapter converts
its own protocol into these outcomes. The port does not assume that two harnesses share
tokens, session rules, or cancellation semantics.

## Start input

A start request contains a run ID, stage ID, attempt, immutable agent profile version,
source workspace reference, scoped task instructions, context source references,
acceptance criteria, timeout, remaining paid-token allowance, and trace context. It contains
secret references, not raw secret values. The adapter resolves only the secrets needed
for that stage. The request carries a task-scoped grant, project provider-policy
revision, paid-token quota revision, and the stage's configured local fallback model
references. The orchestrator checks the grant and records an allow or deny transfer
decision before sending task-required data to a provider.

## Data classification and external transport

Each project defines its own active data-category IDs. The project Owner or Tech
Lead assigns immutable classification revisions to source or payload object refs.
An agent may request a new label but cannot approve it for its own transfer. The
system may assign a derived artifact the union of its classified inputs' category
IDs; a new source without classified inputs needs an approved label. This lets
later autonomous stages use inherited labels without a new human decision. The
stage declares a purpose and the source refs needed for its task. Before each
nonlocal dispatch, Helio resolves the actual payload refs and their
classification revisions. It denies unknown or unclassified refs. Every actual
payload ref must be in the stage's needed-source manifest. The declared categories
for that dispatch must equal the union of categories on the payload refs; an extra
category is not a minimum scope. These categories must also be inside the live
task grant and the provider's current project policy. A revoked policy blocks
dispatch even if the run snapshot contains an earlier approval. The decision is
persisted before transport and
contains refs and category IDs, not source content or credentials.

This rule also covers prior-resolution context injected at task start, telemetry
exports, and an Open WebUI action that sends project data to Open WebUI or a tool
behind it. Local-only rendering does not create an external transfer. The
[Open WebUI contract](open-webui.md) defines its action boundary.

## Runtime events

Every adapter emits `started`, zero or more `output` and `usage` events, and exactly
one terminal `settled`, `failed`, or `cancelled` event. A command acknowledgement is
not a terminal event. The orchestrator stores each event before updating stage state.
The adapter reports model identity, token use when available, elapsed time, and output
artifact references. Missing usage is `unknown`, never zero. Usage carries billing
class (`paid` or `free_local`) and an observed or estimated marker. The synchronous
Helio ledger, not an asynchronous trace export, decides whether another paid call is
allowed.

## Controls and failure

The port supports cancellation, a liveness probe, a persistent session reference,
and restoration at a stable checkpoint. It also exposes model-switch capability and
a live eligibility probe for configured free local models. Pipeline publication
rejects a harness workflow that cannot preserve a session for quota resumption.
Completed stages are recorded before the next stage starts. A resumed attempt
restores the same task session and workspace revision; a later independent verifier
starts with clean scoped context. An interrupted in-flight model call may need a new
attempt and must not be reported as an exact mid-call continuation.

Before a paid call, the state owner atomically reserves a bounded token allowance
against the run's paid-token quota, including concurrent branches. It reconciles the
reservation with provider usage; unknown usage retains its reservation. When no
paid allowance remains, the orchestrator selects a configured, live-probed free
local model that meets the stage capabilities and runs the same quality gates. If
none is eligible, it writes a checkpoint and marks the run `pending` with reason
`quota_exhausted`. A pending run makes no model calls. Only a Project Owner or Tech
Lead may raise the quota. After checkpoint validation, the orchestrator resumes the
same run without repeating completed stages. A missing or invalid checkpoint blocks
resumption and preserves evidence for recovery.

A timed-out or disconnected adapter produces a failed attempt with its last known
evidence. Retries get a new attempt number and clean scoped context unless they
restore a quota-pending session. The orchestrator enforces retry bounds and quality
gates independently of the adapter.

## Adapter-specific validation

- **Pi Agent**: Validate JSONL RPC handshake, command acknowledgement, terminal event,
  cancellation, persistent session reopen, model switch, process failure, and isolated
  process or container execution. The adapter must not use `--no-session` for a
  resumable workflow. The
  [Pi RPC contract](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/rpc.md)
  supplies the adapter protocol.
- **Devin**: Validate service or local token scope and API lifecycle separately from
  Pi. The [Devin authentication guide](https://docs.devin.ai/api-reference/authentication)
  does not define a shared Pi token contract.
- **Other harnesses**: Publish capabilities before an agent profile can select them.
  Unsupported controls are rejected at pipeline validation.

The test harness supplies fake adapters for success, failure, timeout, cancellation,
missing usage, quota exhaustion, eligible local fallback, and checkpoint restoration.
Those fixtures verify orchestration without spending model tokens.
