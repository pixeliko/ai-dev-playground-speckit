# Feature Specification: Helio Agent Platform

**Feature Branch**: `speckit`
**Created**: 2026-09-23
**Status**: Draft
**Input**: Stakeholder briefing supplied for the helio constitution, reused by request for this specification.

## Clarifications

### Session 2026-09-24

- Q: Which project data may be sent to external models and services during a run? → A: Only task-required data may go to providers approved for that project; record each transfer.
- Q: Who may approve external providers and control runs for each project? → A: Project Owners and Tech Leads administer these actions; other people receive assigned read or run permissions, and agents use limited delegated permissions.
- Q: What acceptance does a reconstructed baseline need before autonomous changes to an existing project? → A: The platform accepts it automatically when defined checks pass; failed or inconclusive checks block autonomous changes.
- Q: When may a run start after the project interview generates a specification? → A: Normal mode requires Project Owner or Tech Lead approval; autonomous or sandbox mode may accept it automatically when recorded checks pass.
- Q: What happens when a run reaches its configured paid-model token quota? → A: Stop paid-model calls and use an eligible free local model configured in that run's harness workflow. If none is available, mark the run pending, preserve its session, and resume it after an authorized quota increase.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Define a Project Through a Guided Interview (Priority: P1)

A Product Owner describes a new project or a change to an existing project in a guided
conversation. The platform records goals, constraints, acceptance criteria, unknowns, and
dependencies. It produces a reviewable specification and two roadmaps: one for the stated
human squad and one for the selected agent pipeline.

**Why this priority**: Every later workflow needs a clear, reviewable definition of work.

**Independent Test**: Start from a blank project, complete the interview, and inspect the
resulting specification and both roadmaps without running any agents.

**Acceptance Scenarios**:

1. **Given** a new project, **When** the Product Owner completes the interview, **Then**
   the platform records the answers and generates a specification with traceable requirements.
2. **Given** an incomplete answer, **When** the user resumes the interview, **Then** prior
   answers remain available and unresolved questions remain visible.
3. **Given** a reviewed specification, **When** the user requests estimates, **Then** the
   human roadmap identifies the stated squad, parallel work, blockers, and assumptions, and
   the agent roadmap identifies pipeline stages, model effort, checks, time, and token budget.
4. **Given** a generated specification, **When** execution is requested in normal mode,
   **Then** a Project Owner or Tech Lead must approve it before the run starts.
5. **Given** a generated specification in autonomous or sandbox mode, **When** all defined
   checks pass, **Then** the platform records automatic acceptance and permits the run.
   A failed or inconclusive check blocks the run.

---

### User Story 2 - Configure and Run Agent Pipelines (Priority: P2)

A Tech Lead builds a catalog of agent profiles and assembles them into reusable development
pipelines. A pipeline can triage work, run sequential or parallel stages, seek consensus,
repeat failed work, apply objective gates or evaluator judgments, and escalate reasoning effort.

**Why this priority**: Reusable pipelines turn project definitions into controlled execution.

**Independent Test**: Use a prepared specification and fixture agents to configure one
pipeline, run it, and inspect stage decisions, checks, and final status.

**Acceptance Scenarios**:

1. **Given** agent profiles with harness, model, instructions, skills, and knowledge sources,
   **When** the Tech Lead publishes a pipeline, **Then** its stages and decision rules are
   recorded and reusable.
2. **Given** a run with parallel stages, **When** all branches finish, **Then** the configured
   consensus or judge rule determines whether the run advances.
3. **Given** a failed quality gate, **When** the configured retry or escalation rule applies,
   **Then** the run records the failure and the selected next step.
4. **Given** a paused or failed run, **When** an operator opens its dashboard, **Then** the
   current stage, agent activity, evidence, and available recovery action are visible.
5. **Given** a stage that needs an external provider, **When** the provider is not approved
   for the project, **Then** the platform blocks the transfer and records the reason.
6. **Given** a member or agent without the required project permission, **When** it tries
   to approve a provider or control a run, **Then** the platform rejects and records the action.
7. **Given** a run at its paid-model token quota and an eligible free local model in its
   launched workflow, **When** work continues, **Then** the platform uses that local model
   and applies the same acceptance checks.
8. **Given** a run at its paid-model token quota without an eligible local model, **When**
   the limit is reached, **Then** the platform marks the run pending and saves its session.
   After an authorized quota increase, it resumes the same run from that saved point.

---

### User Story 3 - Prepare an Existing Project for Autonomous Work (Priority: P2)

A Tech Lead connects one or more repositories for an existing project. The platform maps
their architecture, behavior, dependencies, history, and available documentation. It proposes
a recovered project specification and change history for inspection. The platform evaluates
the reconstructed baseline against project-defined checks before an autonomous pipeline can
change the project.

**Why this priority**: Existing projects need a verified baseline to protect human work.

**Independent Test**: Import a prepared project with more than one repository and a known
history, then inspect the recovered map and the baseline acceptance result without changing
source code.

**Acceptance Scenarios**:

1. **Given** related repositories, **When** the Tech Lead starts reconstruction, **Then**
   the platform presents repository relationships, interfaces, known behavior, and source
   evidence for each claim.
2. **Given** commit history or a change log, **When** reconstruction finishes, **Then** the
   platform proposes a reviewable change history and candidate specifications.
3. **Given** missing or conflicting evidence, **When** baseline checks fail or are
   inconclusive, **Then** the uncertainty and evidence are visible and autonomous changes
   remain blocked.
4. **Given** a reconstructed baseline with passing project-defined checks and no blocking
   gaps, **When** evaluation completes, **Then** the platform accepts that baseline version
   automatically and records the check results.

---

### User Story 4 - Compare Execution Strategies (Priority: P3)

A Tech Lead runs the same approved specification through different agent pipelines in
isolated workspaces. The platform preserves each result and compares quality, elapsed time,
model use, and token cost without mixing outputs.

**Why this priority**: Strategy comparisons support informed quality and cost decisions.

**Independent Test**: Run one specification through two fixture pipelines and compare their
separate outputs, checks, and resource records.

**Acceptance Scenarios**:

1. **Given** one approved specification, **When** two strategies are launched, **Then**
   each run has an isolated workspace and traceable source revision.
2. **Given** completed runs, **When** the user opens the comparison, **Then** it shows
   outcomes, failed or passed checks, elapsed time, models, tokens, and decisions per run.
3. **Given** a selected result, **When** the Tech Lead prepares handoff, **Then** the
   platform identifies the exact output and records why it was selected.

---

### User Story 5 - Review Prototypes and Deployment Environments (Priority: P3)

A Product Owner reviews static prototypes against controlled mock systems. A Tech Lead defines
resources and configuration for Local, Dev, Pre, and Pro, then validates a chosen deployment
target before a release decision.

**Why this priority**: Reviewable prototypes and environment definitions reduce deployment
surprises and support comparison of agent outputs.

**Independent Test**: Open one generated prototype with its mock services and inspect the
four environment definitions and target-specific validation evidence.

**Acceptance Scenarios**:

1. **Given** a completed prototype, **When** the user starts its review environment, **Then**
   the prototype and mocks work together without resource collisions with another review run.
2. **Given** a project, **When** the Tech Lead opens deployment settings, **Then** Local,
   Dev, Pre, and Pro can each hold their own service and resource configuration.
3. **Given** a target selected from local macOS, local Windows WSL2, or AWS, **When** the
   Tech Lead requests validation, **Then** the platform reports missing configuration and
   the result of checks before deployment.

---

### User Story 6 - Inspect Project Knowledge and Agent Evidence (Priority: P3)

A Product Owner, Tech Lead, or agent reviews the decisions, recurring issues, resolutions,
tasks, run traces, and quality evidence accumulated during project work.

**Why this priority**: Persistent evidence lets agents learn from earlier work and helps
humans audit autonomous decisions.

**Independent Test**: Complete a fixture task with a decision and failure, then retrieve
the decision, resolution, task record, and run metrics from the project workspace.

**Acceptance Scenarios**:

1. **Given** an architecture decision, **When** it is recorded, **Then** its context,
   selected option, alternatives, rationale, and affected work are retrievable.
2. **Given** a recurring failure, **When** an agent starts similar work, **Then** relevant
   prior resolutions are available with source references.
3. **Given** a completed run, **When** the user inspects it, **Then** stage traces,
   model use, tokens, elapsed time, verification results, and task status are available.
4. **Given** a project task, **When** the user chooses a supported export, **Then** it can
   be represented as Markdown or a tracker issue without losing its project link.

### Edge Cases

- A repository is unavailable, has no usable history, or conflicts with another repository.
- A pipeline stage times out, produces no result, or reaches its paid-model token quota.
- A configured local fallback is unavailable or cannot perform the required stage.
- A pending run loses access to its saved session or receives an invalid quota increase.
- A consensus or evaluator result is inconclusive, or no quality threshold is configured.
- A deterministic check fails after an earlier successful run.
- Two review environments request the same resource name or network port.
- An agent profile refers to a model, skill, or knowledge source that is unavailable.
- A user hands a project to a human team and later imports changes made outside the platform.
- A deployment target lacks credentials, certificates, artifacts, or required configuration.
- A user stops, resumes, or retries a run after some stages have already completed.
- A stage requests project data outside its declared scope or an unapproved provider.
- A member or agent attempts an action outside its assigned project permissions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The platform MUST let users create greenfield projects and register brownfield
  projects from one or more repositories.
- **FR-002**: The platform MUST guide users through an interview that records goals, scope,
  constraints, acceptance criteria, risks, and unanswered questions.
- **FR-003**: The platform MUST produce a reviewable specification and preserve its links to
  interview answers and later changes.
- **FR-004**: The platform MUST produce separate human and agent roadmaps. Each roadmap MUST
  show dependencies, parallel work, blockers, time assumptions, and its resource assumptions.
- **FR-005**: The platform MUST maintain reusable agent profiles that identify a harness,
  model, instructions, skills, and knowledge sources.
- **FR-006**: The platform MUST let a Tech Lead define pipeline stages for triage, sequential
  work, parallel work, consensus, retries, evaluator judgments, objective checks, and reasoning
  escalation.
- **FR-007**: The platform MUST require recorded acceptance criteria and quality gates before
  an autonomous run starts. It MUST retain evidence for each pass, failure, retry, and override.
- **FR-008**: The platform MUST expose the status and activity of every agent and stage in a run.
  Operators MUST be able to stop, resume, and inspect a run.
- **FR-009**: The platform MUST reconstruct a reviewable brownfield baseline from repository
  structure, interfaces, behavior, available documents, history, and change logs.
- **FR-010**: The platform MUST evaluate each reconstructed baseline against checks defined
  for the project. It MUST accept a baseline version automatically only when every required
  check passes and no blocking gap remains. Failed or inconclusive checks MUST block
  autonomous changes and remain visible with their evidence.
- **FR-011**: The platform MUST preserve human edits and reassess the baseline when a project
  returns after work outside the platform.
- **FR-012**: The platform MUST support isolated runs of the same specification under different
  pipeline strategies and preserve the source revision and output of each run.
- **FR-013**: The platform MUST compare strategy results using quality checks, decisions,
  elapsed time, models, and token use.
- **FR-014**: The platform MUST support reviewable static prototypes with mock systems and a
  combined local review environment that avoids collisions between runs.
- **FR-015**: The platform MUST let users define Local, Dev, Pre, and Pro resource configuration
  for local macOS, local Windows WSL2, and AWS targets.
- **FR-016**: The platform MUST validate target prerequisites and display missing requirements
  before a deployment action is allowed.
- **FR-017**: The platform MUST store architecture decisions, recurring problems, resolutions,
  tasks, and source references as project knowledge available to later agents and humans.
- **FR-018**: The platform MUST record each agent task's model, token use, elapsed time,
  decision path, verification result, and relationship to project work.
- **FR-019**: The platform MUST let users keep tasks as Markdown and export them to a supported
  issue tracker while retaining their links to project work.
- **FR-020**: The platform MUST preserve an audit trail of approvals, overrides, and autonomous
  operating mode for each affected run.
- **FR-021**: The platform MUST verify relevant existing behavior before it accepts a change.
  Where behavior cannot be checked deterministically, it MUST use recorded evaluator criteria.
- **FR-022**: Before sending project data to an external model or service, the platform MUST
  verify that the provider is approved for that project and that the data category is in the
  task's declared minimum scope. It MUST block other transfers and record the provider,
  purpose, data categories, time, and decision without storing the transferred content in
  the transfer log.
- **FR-023**: The platform MUST assign permissions per project. Project Owners and Tech Leads
  MUST be able to approve external providers and administer runs. Other people MUST have
  only their assigned read or run permissions. Agents MUST be limited to the permissions
  delegated for their task. The platform MUST reject and record unauthorized actions.
- **FR-024**: In normal mode, the platform MUST require Project Owner or Tech Lead approval
  of a generated specification before a run. In autonomous or sandbox mode, it MAY accept
  the specification automatically only when all project-defined checks pass. It MUST
  record the mode, checks, acceptance decision, and approver when applicable. Failed or
  inconclusive checks MUST block the run.
- **FR-025**: When a run reaches its configured paid-model token quota, the platform MUST
  stop paid-model calls and continue with an eligible free local model only if that model
  is configured in the run's launched harness workflow. The local path MUST pass the same
  quality gates. If no eligible local model is available, the platform MUST mark the run
  pending with reason 'quota_exhausted', preserve its resumable session state, and make
  no further model calls for that run. After a Project Owner or Tech Lead increases the
  quota, the platform MUST resume the same run from its saved point without repeating
  completed stages. It MUST record the fallback, pending state, quota change, and resume.

### Key Entities *(include if feature involves data)*

- **Project**: A greenfield or brownfield effort, its scope, owner, member permissions,
  repositories, work, and approved external providers.
- **Repository**: A source location, revision, relationships, and recovered evidence.
- **Baseline**: A versioned reconstruction with source evidence, project-defined checks,
  check results, blocking gaps, and automatic acceptance state.
- **Interview**: Questions, answers, unresolved items, and generated work definitions.
- **Specification**: Versioned requirements, acceptance criteria, sources, acceptance
  mode, check evidence, and approval state.
- **Roadmap**: Human or agent work, dependencies, estimates, and resource assumptions.
- **Agent Profile**: Harness, model, instructions, skills, and knowledge sources.
- **Pipeline**: A reusable stage graph, routing rules, checks, and escalation policy.
- **Run**: One pipeline execution against a specification and source revision, with
  paid-model token quota, pending reason, fallback choice, and resumable session state.
- **Stage Result**: Agent output, status, evidence, and resource use within a run.
- **Workspace**: Isolated source and output for a run or strategy.
- **Quality Gate**: Acceptance rule, evaluator type, threshold, and result.
- **Prototype**: Reviewable output and links to its mock systems.
- **Environment**: Named deployment stage, provider target, and resource configuration.
- **Decision Record**: Context, selected option, alternatives, rationale, and affected work.
- **Knowledge Entry**: A problem, resolution, or source-backed finding for later reuse.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A Product Owner can complete one greenfield interview and review a linked
  specification plus both roadmap types without editing generated files.
- **SC-002**: A Tech Lead can define and execute a pipeline that includes triage, parallel
  stages, a quality gate, and an escalation path; every branch has a visible result.
- **SC-003**: A Tech Lead can reconstruct one existing project from multiple repositories
  and identify source evidence and unresolved gaps. A baseline with passing checks and no
  blocking gaps is accepted automatically; a failed or inconclusive check blocks execution.
- **SC-004**: The same approved specification can run under at least two isolated strategies,
  with complete comparison of quality, elapsed time, model use, and tokens.
- **SC-005**: Local, Dev, Pre, and Pro configuration can be reviewed. The three named
  deployment targets can be selected where applicable, with missing prerequisites
  displayed before deployment.
- **SC-006**: Every accepted run has recorded acceptance criteria and verification evidence;
  no known failing regression is marked as passed.
- **SC-007**: A Product Owner and Tech Lead can retrieve a prior decision, the related task,
  and its verification outcome from the project dashboard.
- **SC-008**: A reviewer can open a prototype and its mocks alongside another review run
  without a resource collision.
- **SC-009**: A run cannot send project data to an unapproved provider or outside the
  declared task scope. Every permitted or blocked transfer has an audit record.
- **SC-010**: A member or agent without the required project permission cannot approve
  a provider or control a run; each denied action is recorded.
- **SC-011**: A normal-mode run remains blocked until an authorized person approves its
  specification. An autonomous or sandbox run can start after all specification checks
  pass, and cannot start when a check fails or is inconclusive.
- **SC-012**: At the paid-model token quota, a run makes no further paid-model calls. It
  either continues through a configured eligible local model with the same gates or enters
  pending state. After an authorized quota increase, a pending run resumes from its saved
  point without repeating completed stages.

## Assumptions

- This specification covers the full helio platform as a product program. Each user story
  is a separable delivery slice; planning may sequence them into releases.
- The stated human reference squad is one Product Owner, one Tech Lead, two Backend engineers,
  one DevOps engineer, and one Frontend/UX/QA engineer, all senior and full time.
- Product Owner is a user persona. Project Owner is a project-scoped permission role; a
  Product Owner has that role only when assigned to the project.
- Source material for a brownfield baseline may include repositories, their history, change
  logs, existing specifications, and project documents. Missing sources remain visible gaps.
- A Project Owner or Tech Lead approves generated specifications in normal mode. In
  autonomous or sandbox mode, the platform accepts them under recorded project-defined
  checks. Brownfield baselines use automatic acceptance under their own checks.
- Quality thresholds, paid-model token quotas, and time targets are set per pipeline or
  project. The stakeholder has not supplied universal numerical targets.
- Named technologies, vendors, and integrations in the stakeholder briefing are design
  constraints governed by the constitution and are evaluated in the implementation plan.
- Existing project access, deployment credentials, and corporate network configuration must
  be supplied by the operator before those integrations can be validated.
