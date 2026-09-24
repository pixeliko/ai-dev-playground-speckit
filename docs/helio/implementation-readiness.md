# Helio Implementation Readiness Record

**Status:** Draft for Product Owner and Tech Lead review.
**Prepared:** 2026-09-24. This is a preparation date, not an approval date.
**Feature:** [Helio Agent Platform](../../specs/001-helio-agent-platform/spec.md).
**Implementation gate:** T123. Source code work starts only after both review records
below are complete. A task marked complete in `tasks.md` must have its own evidence.

## Acceptance criteria and planned evidence

The [feature specification](../../specs/001-helio-agent-platform/spec.md) defines
SC-001 through SC-012. The table maps them to the work that will show each result.
No result is claimed as passed in this draft.

| Outcome | Criteria | Planned evidence |
| --- | --- | --- |
| Guided intake and mode-specific acceptance | SC-001, SC-011 | T022-T034 contract, domain, integration, and quickstart Scenario A checks. |
| Bounded agent pipeline and run evidence | SC-002, SC-006, SC-012 | T035-T066 fixture runs, quota checks, independent verifier evidence, and T118 regression check. |
| Project access and controlled external data | SC-009, SC-010 | T125-T129 bootstrap/data-scope checks, T039, T048, T065, T066, and T120 denial and audit checks. |
| Source-backed brownfield baseline | SC-003 | T067-T079 multi-repository reconstruction and automatic acceptance checks. |
| Isolated strategy comparison | SC-004 | T080-T088 two-worktree comparison with one accepted specification revision. |
| Prototype and environment review | SC-005, SC-008 | T089-T102 mock/Compose and target checks; T119 fixture tests; T136-T137 actual macOS and WSL2 host evidence. |
| Living project knowledge | SC-007 | T103-T116 knowledge handoff and T132-T133 prior-resolution retrieval at task start. |

Required deterministic checks run before any subjective evaluator. A judge result
can pass only with a recorded rubric and a project-configured threshold. No
threshold or paid-token budget is approved by this record. Missing, failed, or
inconclusive required evidence blocks acceptance. A failed task requires diagnosis
against the last stable state before retry or model escalation. The full source
contract check and seven quickstart scenarios run at T117 and T122. A fixture
result cannot stand in for actual macOS or WSL2 validation.

## Affected contracts and public interface review

| Contract | Effect to review |
| --- | --- |
| [Swagger 2.0 source](../../specs/001-helio-agent-platform/contracts/openapi.yaml) | Draft session create/read/revoke, project data-category and source-label operations, and transfer audit fields. T008/T134/T117 validate source, foundation, and full runtime coverage. |
| [Agent runtime](../../specs/001-helio-agent-platform/contracts/agent-runtime.md) | Task grants, source classifications, provider-policy check before transport, bounded context, checkpoint and verifier rules. |
| [Open WebUI boundary](../../specs/001-helio-agent-platform/contracts/open-webui.md) | Inbound actions use Helio authorization; any external content transport uses Helio classification and transfer admission. |
| [Dashboard contract](../../specs/001-helio-agent-platform/contracts/ui.md) | Local login/logout, HTMX views, safe A2UI rendering, and role-visible controls. |
| [Events](../../specs/001-helio-agent-platform/contracts/events.md) | Audit, acceptance, gate, run, and usage events remain append-only; local identity and classification changes are separate state-owner audit events. |

The API contract is a draft with no deployed client. The new operations are additive
to that draft. Every later public interface change needs an impact record. An
incompatible published change needs a migration guide before release.

## Architecture decisions for review

**AD-01: Local first-operator identity.** Use a guided one-time local bootstrap,
an opaque revocable session, and project-scoped roles as defined in
[auth-bootstrap.md](auth-bootstrap.md). A required enterprise identity provider
would prevent a fresh local installation from operating without external setup.
A shared default credential would let unrelated users enter a fresh installation.
Either may be reconsidered only with a new recorded decision; an external provider
can later be an identity adapter.

**AD-02: Project data classification.** Use a project-configurable category
registry, approved source labels, and deny unknown or unclassified external
transfers. A fixed global category list would not express each project's data
rules. Allowing unlabeled data to leave would make provider approval and minimum
task scope uncheckable. The current policy revision is checked at each dispatch.

**AD-03: Acceptance wording.** Strategy comparison uses one immutable **accepted
specification revision**. A normal-mode human approval and an autonomous-mode
passing automatic evaluation are two ways to accept a revision. Calling both
"approved" would hide that distinction. Provider-policy approval keeps that name.

**AD-04: Contract check stages.** Run source/generator checks in setup, implemented
foundation operations at the foundation checkpoint, and all Swagger operations
after the endpoints exist. Requiring all-operation runtime coverage during setup
would fail on operations that have not been built. T008, T021, T117, and T134
retain the separate evidence.

Other recorded choices and rejected alternatives are in
[research.md](../../specs/001-helio-agent-platform/research.md) and
[plan.md](../../specs/001-helio-agent-platform/plan.md). The reviewers must
confirm that they accept the choices above and the relevant earlier decisions.

## Review record

| Role | Reviewer | Decision | Date | Evidence or required change |
| --- | --- | --- | --- | --- |
| Product Owner | TODO(PO_REVIEWER) | Pending | TODO(PO_REVIEW_DATE) | Confirm acceptance criteria and delivery scope. |
| Tech Lead | TODO(TECH_LEAD_REVIEWER) | Pending | TODO(TECH_LEAD_REVIEW_DATE) | Confirm contracts, quality checks, architecture choices, and alternatives. |

Do not treat this draft, a completed checklist, or an agent's summary as either
role's review. If a reviewer rejects a choice, update the affected source
contract and this record before starting implementation.
