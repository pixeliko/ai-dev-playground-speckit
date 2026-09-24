# Run Event Contract

**Applies to**: FR-007, FR-008, FR-010, FR-012, FR-013, FR-018, FR-020, FR-022 to FR-025.
**Transport**: `GET /api/v1/projects/{projectId}/runs/{runId}/events` as an
authenticated server-sent event stream. This stream is specified separately from the
Swagger 2.0 JSON API in [openapi.yaml](openapi.yaml).

## Envelope

Each event has a unique, increasing `sequence` within one run. The server sends
`id: <sequence>` for resume. A client may send `Last-Event-ID`; the server then
replays later persisted events before live events. An expired or unknown cursor returns
a documented error and requires a snapshot from `GET .../runs/{runId}`.

```json
{
  "event_id": "opaque-id",
  "run_id": "opaque-id",
  "sequence": 42,
  "occurred_at": "2026-09-23T00:00:00Z",
  "type": "stage.started",
  "stage_id": "opaque-id",
  "attempt": 1,
  "payload": {}
}
```

Required envelope fields are `event_id`, `run_id`, `sequence`, `occurred_at`, and
`type`. Stage fields are required for stage events. Unknown event types must be ignored
by clients and retained in run history.

## Helio domain event types

| Type | Required payload | Meaning |
| --- | --- | --- |
| `run.queued` | specification revision, pipeline version | Run accepted. |
| `run.started` | workspace ID, source revision | Execution began. |
| `acceptance.result` | subject type and revision, mode, decision kind, result, check/evidence references | A specification or baseline was accepted or blocked. A failed or inconclusive required check cannot produce acceptance. |
| `transfer.decision` | provider ID, data categories, policy revision, allow/deny, reason, audit reference | An outbound transfer was checked before dispatch. No content is included. |
| `stage.started` | agent profile version, attempt | Stage began. |
| `stage.output` | output reference, content type | Output is available; secrets are not embedded. |
| `usage.recorded` | provider and model IDs, billing class, observed/estimated/unknown, ledger reference | Model usage was reconciled; unknown is never treated as zero. |
| `quota.exhausted` | quota revision, paid tokens used and reserved | Further paid-model dispatch is blocked. |
| `model.fallback` | stage ID, local model ID, probe reference | The same run continued on an eligible configured free local model. |
| `gate.result` | gate ID, result, evidence reference, threshold reference | A check passed, failed, or is inconclusive. |
| `stage.finished` | state, usage reference | Attempt ended. |
| `run.paused` | reason | Operator or policy paused the run. |
| `run.pending` | reason `quota_exhausted`, checkpoint reference | No eligible local fallback exists; session is saved and model calls stop. |
| `quota.changed` | old and new paid-token quota, actor ID, reason, quota revision | Project Owner or Tech Lead raised the quota. |
| `run.resumed` | reason, checkpoint reference, quota revision | The same run continued without repeating completed stages. |
| `run.finished` | state, summary reference | Run passed, failed, or was cancelled. |

The persisted run and stage state machines in [data-model.md](../data-model.md) define
valid event order. An event with an invalid transition is rejected before publication.
`quota.exhausted` precedes either `model.fallback` or `run.pending`. A quota-pending
run needs `quota.changed` and a valid checkpoint before `run.resumed`. The state owner
persists token reservations, transfer decisions, checkpoints, and events before the
corresponding dispatch or state change. Replayed events retain their original IDs and
sequences.

## AG-UI adapter

The adapter maps persisted Helio events to AG-UI lifecycle, text, tool, and state events
where a documented AG-UI equivalent exists. It keeps the original Helio sequence as
trace metadata. A Helio gate result remains a Helio extension event if AG-UI has no
equivalent. An AG-UI consumer must not infer a pass from a text completion event.
See the [AG-UI event model](https://docs.ag-ui.com/concepts/events).

## Privacy and recovery

Events contain references to artifacts, never raw credentials. The stream is scoped to
an authorized project. A disconnect does not stop a run. A client recovers from the last
persisted sequence. Run history and the JSON snapshot remain available if streaming or
the telemetry sink is unavailable. Transfer decisions record categories and provider,
not source content; telemetry export follows the same project provider policy.
