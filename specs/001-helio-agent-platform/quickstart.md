# Quickstart Validation Guide

This guide defines the end-to-end checks for the planned Helio platform. The
Makefile targets and API service do not exist yet; implementation must provide them
before these scenarios can be run. The guide does not claim a successful run today.

See [spec.md](spec.md), [data-model.md](data-model.md), and the
[API](contracts/openapi.yaml), [event](contracts/events.md), and
[dashboard](contracts/ui.md) contracts for expected behavior.

## Prerequisites

- macOS with Docker Desktop or Windows WSL2 with Docker Desktop integration and Compose.
- Python 3.13+ for local development and a browser for the dashboard.
- A corporate CA and artifact credentials if this workstation needs them.
- A configured agent harness only for live-agent scenarios. Fixture harnesses must
  support all deterministic orchestration checks without external model access.
- A disposable Git repository fixture with a documented history and, for brownfield
  checks, a second related repository.
- Operator identity and a test token supplied through the installer or secret store.
  Do not put a token in a committed file.
- Fixture identities for a Project Owner, Tech Lead, runner, viewer, and task-limited
  agent. Fixture providers include an approved provider and an unapproved provider.

## Planned local setup

```sh
make install
make doctor
make local-up
make contract-check
make verify
```

`make install` runs the guided setup. `make doctor` reports Docker, Python,
certificate, artifact, model, and optional integration status. Required failures
block the related scenario and identify a remedy. `make local-up` starts the API,
dashboard, state owner, and fixture worker under one Compose project name. It must
print the dashboard URL and assigned host port. `make contract-check` validates
the Swagger 2.0 source and exercises the pinned generator image with a generated
client. `make verify` runs deterministic contract, domain, and integration checks.

## Scenario A: Greenfield intake and roadmaps

1. Open the dashboard URL and create a greenfield project.
2. Complete the interview with a goal, constraint, acceptance criteria, and one
   unanswered question. Resume the interview and answer that question.
3. Generate a specification in normal mode. Verify that a runner cannot start a run
   until the Project Owner or Tech Lead accepts that revision. Record the decision.
4. Generate another revision in autonomous or sandbox mode. Make one required check
   inconclusive, then pass all checks and inspect the automatic decision.
5. Generate the human and agent roadmaps.
6. Review trace links from the specification to answers. Check that the human
   roadmap uses the stated six-person squad and marks blocking work. Check that
   the agent roadmap shows stage assumptions, model effort, checks, time inputs,
   and a configurable paid-model token quota, local fallback assumptions, and
   checkpoint requirements.

**Expected**: The normal-mode run is blocked before authorized acceptance. The
automatic acceptance is blocked by an inconclusive check and succeeds only after
all required checks pass. Both roadmaps are visible; neither contains a numeric
estimate without its input and derivation.

## Scenario B: Pipeline quality and recovery

1. Create fixture agent profiles and a pipeline with triage, two parallel work
   stages, a join, a deterministic gate, and bounded escalation.
2. Publish the pipeline and start a run against an accepted fixture specification.
3. Make the first gate fail, then let the configured retry pass.
4. Pause and resume another run. Reconnect its event stream with the last event ID.

**Expected**: The dashboard shows every attempt and check. A failed attempt remains
in history. The verifier has a separate task context. The resumed event stream
replays missed events without duplicates. Missing thresholds or unbounded loops
prevent publication. See [agent-runtime.md](contracts/agent-runtime.md).

## Scenario C: Brownfield baseline

1. Import two related fixture repositories with commits, a change log, and a
   deliberate conflict between a document and code.
2. Start reconstruction and inspect each finding's source reference and
   observed, inferred, or unverified class.
3. Attempt an autonomous run while baseline checks are inconclusive. Resolve the
   blocking conflict, evaluate a new baseline version, and retry after all required
   checks pass.

**Expected**: The first run is rejected. The passing baseline version is accepted
automatically and allows the new run. The prior conflict and check results remain
visible. An external human edit triggers a new baseline version and evaluation
before later autonomous changes.

## Scenario D: Strategy comparison and prototype review

1. Launch the same accepted specification through two fixture pipeline versions.
2. Open the comparison. Inspect source revision, isolated workspace, gate results,
   elapsed time, model IDs, and token counts for each run.
3. Start both prototype review environments with mocks.

**Expected**: The runs never share a worktree or output. Both review stacks are
reachable at distinct host ports and use their own Compose project names.
The selected result records its rationale.

## Scenario E: Environment and knowledge checks

1. Define Local, Dev, Pre, and Pro settings and inspect local macOS, local WSL2,
   and AWS targets.
2. Validate one target with a missing prerequisite. For AWS, inspect the
   CloudFormation change set before an update.
3. Record an architecture decision with alternatives, a problem, its resolution,
   and a task. Retrieve them from the project dashboard and export the task.

**Expected**: Missing prerequisites block deployment and show evidence. A change
set is reviewable before an AWS update. Knowledge keeps source links. The
exported task retains its project and specification IDs.

## Scenario F: Project permissions and provider transfers

1. Assign Owner, Tech Lead, runner, and viewer roles within one project. Verify
   that a role in another project gives no access here. Give a fixture agent only
   the current stage's task actions and data categories.
2. Have the Owner approve one external provider for one required data category.
   Attempt a transfer to an unapproved provider and a transfer with an extra
   category, then allow a task-required transfer within the approved policy.
3. Inspect the local transfer audit and exported trace. Revoke the provider and
   attempt another transfer.

**Expected**: Owner and Tech Lead can manage roles and provider policy. Runner
and viewer can only perform their assigned actions. The agent cannot exceed its
task grant. Denied transfers send no data. Each decision records provider,
categories, purpose, policy revision, and reason without recording content or
credentials. A trace outage does not remove the local audit record.

## Scenario G: Paid quota, local fallback, and session resume

1. Start two concurrent fixture stages with a small paid-token quota. Confirm
   their reservations cannot exceed the shared allowance. Return unknown usage
   for one call and confirm its reservation remains held.
2. Exhaust the paid allowance with a configured, live-probed free local model that
   meets stage capabilities. Verify it continues under the same quality gates.
3. Repeat with no eligible local model. Confirm the run becomes `pending` with
   `quota_exhausted`, saves a persistent session checkpoint, and makes no calls.
4. As a runner, try to raise the quota. Then have the Owner or Tech Lead increase
   it. Resume from the saved checkpoint and inspect completed-stage history.
5. Corrupt a disposable checkpoint and verify that resume is blocked with a
   recoverable error and retained evidence.

**Expected**: No paid call starts beyond the reserved quota. Local tokens are
recorded separately. The pending run is not marked failed, and only an authorized
quota increase permits the same run to resume. Completed stages do not repeat;
an interrupted in-flight call may restart as a new recorded attempt.

## Teardown

```sh
make local-down
```

The teardown removes disposable review stacks and ports created for these tests.
It must not delete repositories, accepted baselines, decisions, or run evidence.
