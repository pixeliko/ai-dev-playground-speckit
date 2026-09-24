# Open WebUI Action Boundary

**Applies to**: FR-005, FR-008, FR-022, FR-023.
Open WebUI can show Helio actions through an API or MCP adapter. Helio remains the
source of project permissions, run state, decisions, and transfer audit. This
contract does not require Open WebUI to implement AG-UI or A2UI.

## Action input and output

An action request identifies the authenticated operator, project ID, action name,
target resource revision, task or run ID when relevant, and a request ID. The
adapter accepts only named Helio actions such as list projects, inspect a run, or
request an authorized run control action. It rejects arbitrary tool names,
unbounded commands, and unknown fields. It checks the operator's project role and
any delegated agent grant through the same application port used by the machine
API. A denial returns a reason and an audit reference, not protected content.

The response contains only fields allowed by the operator's project role. It
includes stable Helio resource IDs and an optional dashboard link. It does not
return credentials, hidden prompts, or unrestricted repository contents.

## Data transport

Inbound actions from Open WebUI do not grant outbound data access. Before Helio
sends project content to an Open WebUI instance or tool outside the project's
local boundary, Helio resolves the content's source refs and project classification
revisions.
It requires each payload ref to be in the task's needed-source manifest. The
declared categories for the dispatch must equal the union of the payload labels
and fit the task grant and current approved provider policy. It persists an allow
or deny decision before transport. Unknown or unclassified content is denied. A
revoked provider policy stops later sends even when a run began under an earlier
revision.
The same rule applies if the action starts an agent run, and the run engine checks
each later external dispatch again. A local Open WebUI instance still uses Helio
role and task-grant checks. A local-only dashboard link does not send project
content to an external provider.

## Declarative UI

If an action returns an A2UI payload, the dashboard validates it against its
bounded component catalog before rendering. Unknown components and unsafe links
render as inert text. The payload cannot bypass a Helio authorization or transfer
decision. See [ui.md](ui.md) for HTML and A2UI behavior.

## Verification

Contract tests use one allowed and one denied action, a revoked provider policy,
an unclassified source, and a task grant with less scope than the requested
content. They assert that no transport occurs before an allow decision, that a
deny decision is visible, and that audit records contain no payload or secret.
