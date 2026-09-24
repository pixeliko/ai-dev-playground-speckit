# Data Model: Helio Agent Platform

**Source**: [spec.md](spec.md) and [research.md](research.md).
**Scope**: Logical entities and validation rules. Storage tables and migrations belong to
implementation.

## Shared conventions

- IDs are opaque strings. The API does not expose storage row numbers.
- Timestamps are UTC instants. A record with revisions keeps its prior revisions.
- Every project-owned record has a project ID, creator, creation time, and last change time.
- Cross-project references require an explicit shared catalog item; other references stay
  inside one project.
- Secret values are never stored in these entities. Configuration holds secret references.
- A Project Owner or Tech Lead approves provider policy and quota changes. A member's
  project permission and an agent's task grant are checked on every affected action.
- Transfer decisions and quota reservations are committed by the state owner before
  an external call starts. A remote trace is a copy, not the audit source.
- A source-backed finding records repository ID, revision, file or document path, and
  location where available. An inference is marked as an inference.
- State changes append an event before updating the current view.

## Project and source context

| Entity | Main fields | Relationships and rules |
| --- | --- | --- |
| Project | id, name, kind (greenfield/brownfield), owner_id, status, description, provider_policy_revision | Has repositories, interviews, specifications, runs, environments, and knowledge. Name is unique within an owner workspace. |
| ProjectMembership | id, project_id, person_id, role, active_from, active_to | Roles are Project Owner, Tech Lead, runner, or viewer. One active Project Owner is required. A person may hold more than one permitted role. |
| AgentGrant | id, project_id, run_id, stage_id, agent_profile_id, allowed_actions, data_categories, expires_at | A grant is task-scoped, cannot exceed the issuing operator's project permissions, and expires after the task. |
| ProviderPolicy | id, project_id, revision, provider_id, permitted_data_categories, approved_by, approved_at, status | Only a Project Owner or Tech Lead can approve a provider. Revisions are immutable; a run records the revision used. |
| TransferDecision | id, project_id, run_id, stage_id, provider_id, purpose, data_categories, policy_revision, decision, reason, occurred_at, request_id, coarse_size | Records allow or deny before dispatch. It stores no transferred content or credentials. |
| Repository | id, project_id, remote, default_ref, observed_revision, access_state | A project has one or more repositories for brownfield work. A repository may link to another repository by a typed relationship. Credentials are referenced, not stored. |
| RepositoryRelation | id, source_repository_id, target_repository_id, relation_type, evidence | Both repositories must belong to the same project. |
| SourceEvidence | id, project_id, repository_id, revision, source_path, locator, extraction_kind, summary | Extraction kind is observed, inferred, or user supplied. A cited path and revision are required for observed code findings. |
| Baseline | id, project_id, version, status, source_revision_set, check_set_revision, acceptance_decision_id | A brownfield baseline references evidence and known behavior. It is accepted automatically only when all required checks pass and no blocking gap remains. |
| BaselineFinding | id, baseline_id, category, claim, confidence_class, evidence_ids, blocking | Every claim has evidence or is labeled unverified. Conflicting claims retain both sources. |
| BaselineCheckResult | id, baseline_id, check_id, result, evidence_ref, checked_at | Result is passed, failed, or inconclusive. Every required result must pass before automatic acceptance. |

**Project states**: draft → defined → active → archived. Brownfield projects require an
accepted baseline before active autonomous execution. A returned project gets a new
baseline version when external changes are found.

**Baseline states**: collecting → evaluating → accepted or blocked. A failed or
inconclusive required check or a blocking finding leads to blocked. New evidence
creates a new version; it does not rewrite an accepted version.

## Intake and planning

| Entity | Main fields | Relationships and rules |
| --- | --- | --- |
| Interview | id, project_id, status, started_at, resumed_at | Contains question and answer records. One project may have several interview revisions. |
| InterviewAnswer | id, interview_id, question_key, answer, source, answered_at | An unanswered item remains explicit. The author can correct an answer with a new revision. |
| Specification | id, project_id, revision, status, source_interview_id, source_baseline_id, owner_id, acceptance_decision_id | Contains requirements and acceptance criteria. A run points to one immutable accepted revision. |
| Requirement | id, specification_id, text, priority, source_refs, acceptance_refs | A requirement is linked to at least one acceptance criterion before acceptance. |
| AcceptanceCriterion | id, specification_id, requirement_ids, check_type, expected_result, threshold_ref | Deterministic checks have a fixture and expected result. Judge checks have a rubric and threshold. |
| AcceptanceDecision | id, project_id, subject_type, subject_id, subject_revision, mode, kind, result, required_check_refs, evidence_refs, actor_id, decided_at | Subject is specification or baseline. Kind is manual or automatic. A manual specification decision needs a Project Owner or Tech Lead actor. An automatic decision needs all passing checks. |
| Roadmap | id, specification_id, kind (human/agent), revision, assumptions, critical_path | A specification may have both kinds. Estimate inputs and derivation are retained. |
| RoadmapItem | id, roadmap_id, work_label, owner_role_or_agent, effort_input, dependency_ids, blocking | Dependencies must form an acyclic graph. Parallel groups are derived from that graph. |

**Interview states**: open → ready_for_review → closed. An interview can return to open
when new facts emerge.

**Specification states**: draft → review_required (normal mode) or evaluating
(autonomous/sandbox) → accepted or blocked → superseded. Normal-mode acceptance
needs a Project Owner or Tech Lead decision. Automatic acceptance needs passing
project-defined checks. A failed or inconclusive check blocks a run. Accepted
revisions are immutable; a new revision starts at draft.

## Agent catalog and pipeline

| Entity | Main fields | Relationships and rules |
| --- | --- | --- |
| AgentProfile | id, version, name, harness_ref, model_ref, instruction_ref, skill_refs, knowledge_refs, availability | Published versions are immutable. Credentials are referenced by environment. |
| ModelCapability | id, provider, runtime, model_id, revision, checksum, license, hardware_need, capabilities, probe_result, billing_class | A profile may select a model only for a capability the live probe confirms. Billing class is paid or free_local. |
| Pipeline | id, version, name, status, entry_stage_id, author | Published versions are immutable. A run uses one published version. |
| PipelineStage | id, pipeline_id, stage_type, agent_profile_id, local_fallback_model_refs, required_capabilities, input_contract, output_contract, timeout_policy | Stage types cover triage, work, join, gate, judge, and escalation. Fallback references belong to the published workflow version. |
| StageEdge | id, pipeline_id, from_stage_id, to_stage_id, predicate, priority | Edges form a valid directed graph. Cycles require an explicit retry limit or budget rule. |
| GateDefinition | id, pipeline_id, stage_id, kind, fixture_ref, rubric_ref, threshold, fallback_rule | A judge gate needs a rubric and threshold before publishing. |
| EscalationPolicy | id, pipeline_id, trigger, next_profile_id, max_attempts, paid_token_quota_rule | The policy must terminate or enter a bounded pending state. It cannot schedule paid calls after quota exhaustion. |

**Pipeline states**: draft → validated → published → retired. Validation rejects an
unreachable exit, missing agent profile, undefined join rule, unbounded cycle, or a
harness workflow unable to preserve the session state needed for quota resume.

## Execution and evidence

| Entity | Main fields | Relationships and rules |
| --- | --- | --- |
| Workspace | id, project_id, repository_revision_set, strategy_key, worktree_refs, isolation_ref | A strategy run owns its worktrees and review environment. |
| Run | id, project_id, specification_id/revision, baseline_id/version, pipeline_id/version, workspace_id, mode, state, pending_reason, paid_token_quota, paid_tokens_used, checkpoint_id, started_at, ended_at | It snapshots acceptance and provider-policy revisions. A quota increase changes only the quota revision; specification and pipeline versions remain fixed. |
| RunEvent | id, run_id, sequence, event_type, stage_id, agent_id, occurred_at, payload_ref | Sequence is unique within a run. Events are append-only and support replay. |
| StageResult | id, run_id, stage_id, attempt, state, output_ref, evidence_refs, started_at, ended_at | Attempts are distinct. A retry does not overwrite failed evidence. |
| GateResult | id, run_id, stage_id, attempt, gate_id, result, measured_value, evaluator_ref, evidence_ref | A pass requires the configured evidence and threshold. |
| TokenReservation | id, run_id, stage_id, provider_id, reserved_tokens, actual_tokens, state, created_at, reconciled_at | One state-owner transaction reserves paid tokens before dispatch. Unknown usage holds the reservation until reconciled. |
| QuotaChange | id, run_id, previous_limit, new_limit, actor_id, reason, changed_at | Only a Project Owner or Tech Lead can raise the quota. The change is append-only and cannot erase prior usage. |
| RunCheckpoint | id, run_id, stage_id, session_ref, workspace_revision, completed_stage_refs, pending_work_ref, quota_ledger_revision, created_at | Persisted at stable boundaries and before pending. A checkpoint does not include raw secrets. |
| ResourceUsage | id, run_id, stage_result_id, provider_id, model_id, billing_class, input_tokens, output_tokens, total_tokens, usage_state, elapsed_ms, trace_id | Counts are nonnegative. Usage state is observed, estimated, or unknown; unknown is not zero. Local tokens are tracked but do not spend the paid quota. |
| DecisionRecord | id, project_id, context, choice, alternatives, rationale, author, source_refs, affected_refs | Records architecture and run decisions; alternatives may be empty only with a reason. |
| KnowledgeEntry | id, project_id, kind, title, summary, source_refs, decision_ref, supersedes_id | Kind includes problem, resolution, and finding. A later correction links to the old entry. |
| TaskRecord | id, project_id, specification_id, status, owner, evidence_refs, markdown_ref, issue_ref | Markdown and issue representations retain the same stable task ID. |

**Run states**: queued → preparing → running ↔ paused → verifying → passed or failed
or cancelled. At the paid quota, an eligible local fallback keeps the run in running.
If no eligible fallback exists, running → pending with reason `quota_exhausted`.
After an authorized quota increase, pending → running from the same checkpoint.
Pending makes no model calls. Resume appends events and does not repeat completed stages.

**Stage states**: queued → running → passed or failed or skipped or cancelled.
A stage cannot pass until its gate results are recorded.

## Review and deployment

| Entity | Main fields | Relationships and rules |
| --- | --- | --- |
| Prototype | id, run_id, output_ref, mock_refs, review_environment_id, status | Points to an immutable run output. |
| MockService | id, prototype_id, contract_ref, fixture_ref, health_ref | A prototype can reference several mocks. |
| ReviewEnvironment | id, project_id, run_id, compose_project_name, assigned_ports, state | Active project names and published ports are unique on one local host. |
| Environment | id, project_id, name, target, revision, config_ref, secret_refs | Name is Local, Dev, Pre, or Pro. Target is local macOS, local WSL2, or AWS. |
| EnvironmentCheck | id, environment_id, revision, check_name, state, evidence_ref, checked_at | A deployment action is blocked while required checks fail or are unknown. |
| DeploymentRecord | id, environment_id, revision, source_run_id, approval_ref, change_set_ref, state | References one validated environment revision and one source run. |

**Review environment states**: defined → starting → ready → stopped or failed.
**Deployment states**: proposed → validated → approved → applying → deployed or failed
or rolled_back. A failed deployment keeps its validation and change-set evidence.

## Relationship overview

```text
Project ── ProjectMembership ── AgentGrant
   ├── ProviderPolicy ── TransferDecision
   ├── Repository ── SourceEvidence ── Baseline ── BaselineCheckResult
   ├── Interview ── Specification ── AcceptanceDecision ── Roadmap
   ├── Environment ── EnvironmentCheck ── DeploymentRecord
   ├── DecisionRecord ── KnowledgeEntry
   └── Run ── Workspace ── Prototype ── ReviewEnvironment
        ├── Pipeline version ── Stage ── GateDefinition
        ├── RunEvent ── RunCheckpoint
        ├── StageResult ── GateResult
        ├── TokenReservation ── QuotaChange
        └── ResourceUsage
```
