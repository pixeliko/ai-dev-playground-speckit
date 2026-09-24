# helio Constitution

## Core Principles

### I. Talk Spanish Read English

Agents MUST communicate with users in Spanish. Code and code comments MUST be in English.
Project documentation, specifications, and stored reports MUST be in English and follow
ASD-STE100 Simplified Technical English. The change author MUST check these language rules
before review. The reviewer MUST inspect user-facing messages and changed artifacts as evidence.
This keeps the user conversation accessible while giving human teams and future agents one
consistent written record. Autonomous, sandbox, or bypass mode does not waive the language rule.

### II. Progressive Effort

For each agent task, the orchestrator MUST start an execution agent with a clean task context
and retrieve only the material needed for that task. A separate agent with a clean context
MUST verify the result before the task is accepted. The verifier MUST use deterministic tests
for behavior that can be checked deterministically; subjective checks MAY use an LLM as judge
only against recorded, configurable acceptance criteria and thresholds. Failed checks MUST
trigger diagnosis against the last stable state and then a documented retry or escalation
in reasoning time or model capability. The orchestrator MUST record the task, context sources,
checks, outcome, model, token use, elapsed time, and escalation decision. These records make
quality and cost review possible without assuming that the most expensive model is needed
first. The task owner checks the record at task completion; the independent verifier signs
off the evidence. TODO(QUALITY_THRESHOLDS): define thresholds per task or evaluation policy
before treating an LLM judgment as a pass.

### III. Contract-Led Modular Evolution

Every new or changed product capability MUST define its API contract before implementation,
use explicit domain boundaries under Domain-Driven Design, and isolate domain logic from
external systems through Hexagonal Architecture ports and adapters. Modules MUST expose
documented contracts so they can be assembled or replaced independently. The change author
MUST document the effect of each public interface change and provide a migration guide for
incompatible changes. For brownfield work, the team MUST first reconstruct and record the
relevant repository architecture, contracts, history, and existing behavior before autonomous
changes begin. Verification MUST check that the contract and existing behavior still pass,
including local container startup and connectivity when those paths are affected. The
Tech Lead or designated reviewer checks contracts, boundary diagrams or equivalent design
records, migration evidence, and test results before publication. This lets projects pass
between agents and human teams without losing the knowledge needed for later changes.

## Additional Constraints

**Adopted constraints.** Relevant feature specifications and plans MUST account for the
agreed baseline: Python 3.13+, DuckDB, API-first contract generation with
`swaggerapi/swagger-generator`, HTMX, AG-UI, A2UI, ShadCN visual style, Open WebUI, and a local
Docker Compose environment for macOS and Windows WSL2 with a guided Makefile installer.
Frontend designs MUST use HTMX for interaction and follow the ShadCN visual style. They
do not require the official React ShadCN components.
Deployment designs MUST cover Local, Dev, Pre, and Pro environments and the stated provider
targets: local macOS, local Windows WSL2, and AWS CloudFormation. Designs that use external
artifacts or agent execution MUST account for corporate CA handling, authenticated JFrog
CLI access for npm, uv, and Hugging Face, and the configured local Devin Enterprise token
path for Pi Agent. Agent observability designs MUST account for Langfuse and OpenTelemetry.
Local model designs MUST account for Ollama and the named model set: Devstral Small 24B,
Cactus Needle 3, Nemotron-3-Embed-8B-BF16, Qwen3-TTS, and VibeVoice 7B. Triage designs
MUST assess decidr as the named decision library for local models.
The feature specification MUST state which constraints apply to that feature; this list
does not require every component to run in every deployment.

**Reported practices and references.** The stakeholder reports current use of OpenCode,
Pi Agent, and Devin CLIs; Spec Kit for specification-driven development; Graphify for code
documentation; and OpenKB for general documentation. `docs/brand/` is the supplied visual
style reference. These reports are context, not independent proof that an integration works.
Markdown tasks and GitHub or GitLab issues are requested persistence options, not a choice
of a single mandatory tracker. Graphify and OpenKB MAY be evaluated for brownfield
reconstruction and the project's living knowledge record; adopting either in a feature
requires a documented design decision.

**Open design inputs.** TODO(INITIAL_CONTEXT_INPUT): complete the unfinished requirement
about permitted sources of initial documentation or context in a feature specification.

## Development Workflow

Before implementation, the Product Owner and Tech Lead MUST record acceptance criteria,
affected contracts, quality checks, and any architecture decision that selects one option
over another. For conflicting priorities, the decision maker MUST record the recommended
choice, rationale, and rejected alternatives. A change author MUST run relevant deterministic
checks and, when local containers are affected, verify startup, expected responses, and
connectivity. If a check fails, the author MUST inspect changes since the last stable state
before declaring the task complete. An independent reviewer MUST inspect the evidence and
confirm that existing behavior and the stated quality criteria are preserved.

Autonomous, sandbox, or bypass operation MAY relax human-in-the-loop decisions only when the
run mode and the waived decision are recorded. It MUST NOT waive the recorded acceptance
criteria, independent verification, public contract review, or failure evidence. Where
capacity or cost estimates are requested, plans MUST distinguish human work and agent
pipelines, identify parallel and blocking tasks, and record model, token-budget, and
evaluation assumptions; no numerical estimate is set by this constitution.

## Governance

This constitution governs project work. A proposed amendment MUST include the exact text
change, rationale, affected principles or workflows, compatibility impact, and review
evidence. The change author MUST update the Sync Impact Report during review and remove
that temporary comment before commit. The approval authority is not yet agreed:
TODO(AMENDMENT_AUTHORITY): name the role or body that may ratify and approve amendments.
The original ratification date MUST be recorded when approval occurs; it MUST NOT be
inferred from a file edit.

Versions use semantic versioning: MAJOR for incompatible principle or governance changes,
MINOR for new principles, sections, or material guidance, and PATCH for non-semantic
clarifications. This unratified draft is 0.1.1. Once ratified, each amendment MUST
preserve the original ratification date and set Last Amended to its amendment date.
Compliance review MUST occur before publication of a change, using the acceptance record,
contract and migration review, test results, and independent verification as evidence.
The change author is responsible for providing it; the reviewer is responsible for checking it.
An exception MUST identify the specific rule, scope, reason, and compensating check in the
change record. TODO(EXCEPTION_AUTHORITY): name who may approve exceptions; until that role
is agreed, an exception cannot be treated as approved.

**Version**: 0.1.1 | **Ratified**: TODO(RATIFICATION_DATE): not yet ratified |
**Last Amended**: 2026-09-23
