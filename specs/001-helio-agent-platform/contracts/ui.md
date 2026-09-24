# Dashboard and Declarative UI Contract

**Applies to**: FR-002, FR-003, FR-008, FR-010, FR-013, FR-014, FR-017, FR-022 to FR-025.
**Design reference**: `docs/brand/` and ShadCN visual tokens. HTMX handles
interaction. Official React ShadCN components are not required.

## HTML routes

HTML routes are distinct from the machine API in [openapi.yaml](openapi.yaml).
A full-page request returns a complete document. A fragment request returns only the
named region, with `Content-Type: text/html`. If one URL can return both, it must
inspect `HX-Request` and include `Vary: HX-Request`.

| Route | Full page or fragment | Required information |
| --- | --- | --- |
| `/dashboard/projects` | Full page | Project list, kind, current state, next action. |
| `/dashboard/projects/{id}/access` | Full page and policy fragment | Project roles, permitted actions, approved providers and data categories, transfer audit. Owner and Tech Lead see management controls. |
| `/dashboard/projects/{id}/interview` | Full page and question fragment | Current question, prior answers, unanswered items, save result. |
| `/dashboard/projects/{id}/specification` | Full page | Source links, requirements, acceptance criteria, acceptance mode, check evidence, and human decision control in normal mode. |
| `/dashboard/projects/{id}/baselines/{baselineId}` | Full page | Findings, evidence, conflicts, blocking gaps, automatic check results, and acceptance decision. |
| `/dashboard/pipelines/{id}` | Full page and stage fragment | Stage graph, profiles, gates, retry bounds, validation errors. |
| `/dashboard/projects/{id}/runs/{runId}` | Full page and status fragment | Stage status, evidence, paid/local usage, quota, fallback, pending reason, checkpoint, trace link, and permitted controls. |
| `/dashboard/projects/{id}/comparisons` | Full page | Same-specification run outcomes and resource comparison. |
| `/dashboard/projects/{id}/knowledge` | Full page and result fragment | Decisions, problems, resolutions, source links. |
| `/dashboard/projects/{id}/environments` | Full page | Local, Dev, Pre, Pro target configuration and validation. |
| `/dashboard/projects/{id}/prototypes/{prototypeId}` | Full page | Prototype, mock health, review environment, source run. |

Mutation controls show pending, success, and failure states. They preserve user input
after a validation error. A failed operation includes a readable reason and a path to
the underlying evidence. A gate marked inconclusive is visibly distinct from passed.
The dashboard hides actions the current project role or task grant cannot use and the
API enforces the same restriction. A quota-pending run shows that no model calls are
active. Only a Project Owner or Tech Lead sees the paid-token quota increase control;
after a valid increase, the same run shows a resumed checkpoint and retained history.
The provider view shows allow and deny decisions without exposing transferred content.

## A2UI rendering boundary

An A2UI adapter may receive declarative UI payloads from an agent. It validates the
payload against an approved component catalog before rendering it in the dashboard.
Allowed initial concepts are text, status, checklist, evidence link, and bounded choice.
Unknown components and unsafe links are shown as inert fallback content. The payload
cannot run arbitrary script or invoke an unapproved dashboard action. See the
[A2UI project](https://a2ui.org/).

## Open WebUI boundary

Open WebUI can discover Helio actions through a documented API or MCP adapter and link to
the Helio dashboard for detailed run review. Helio's run state and approvals remain in
Helio. Project permissions and provider policy apply to actions initiated through
Open WebUI as well. No dashboard contract assumes Open WebUI has native AG-UI or A2UI
support.

## Accessibility and language

User conversation and visible status text are in Spanish. Stored project documents and
reports are in English. Every status has a text label in addition to color. Forms expose
labels and validation messages, and keyboard users can reach all review and control actions.
Visual tokens use the approved brand source and ShadCN style guidance.
