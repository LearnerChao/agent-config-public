# Spec Refiner Reference

## Type Classification

Classify the user's idea into one of these types based on signals in their description. When ambiguous, ask the user.

| Type | Signals | Examples |
|------|---------|----------|
| **software** | "build", "system", "service", "API", "database", "deploy", "architecture", "backend", "frontend", "microservice", "pipeline" | REST API, data pipeline, CLI tool, web app, infrastructure |
| **product** | "feature", "user", "launch", "experience", "workflow", "onboarding", "conversion", "engagement", "customer" | New product feature, redesign, mobile app, user-facing workflow |
| **scientific** | "hypothesis", "experiment", "measure", "analyze", "effect", "correlation", "sample", "statistical", "A/B test", "causal" | A/B test design, causal analysis, metric investigation, research study |
| **agentic** | "agent", "skill", "prompt", "subagent", "tool", "autonomous", "orchestrator", "LLM", "AI system" | agent skill, agent workflow, LLM-powered tool, multi-agent system |
| **general** | None of the above, or a mix that doesn't fit a specific type | Process design, policy, governance framework, training curriculum |

**Hybrid specs**: When the idea spans multiple types (e.g., "build a product feature that requires an A/B test to validate"), use the primary type for the template skeleton and merge in dimensions from secondary types. Note the hybrid nature in the spec metadata.

---

## Probing Dimensions

Each dimension below includes:
- **What to probe**: The core concern
- **Skeptical angles**: How to challenge the spec in this dimension
- **Seed questions**: Starting questions the questioner adapts to the specific spec

### Universal Dimensions (all types)

#### Scope & Goals
**What to probe**: Clarity of boundaries, measurability of success, presence of non-goals.

**Skeptical angles**:
- Are the goals actually measurable or just aspirational?
- Is the scope creeping beyond what's stated?
- Are there implicit goals hiding behind the explicit ones?
- Are the non-goals truly out of scope, or are they things the author hopes someone else will handle?

**Seed questions**:
- What would a minimal version of this look like that still achieves the core goal?
- What happens if you achieve all the stated goals but users/stakeholders are still unhappy — what's missing?
- Which goals could conflict with each other? How do you prioritize when they do?
- What are you tempted to include that you should explicitly exclude?

#### Assumptions & Constraints
**What to probe**: Hidden assumptions, unstated constraints, things taken for granted.

**Skeptical angles**:
- What would break if any of these assumptions turned out to be false?
- Are constraints real (physics, regulation) or self-imposed (convention, preference)?
- Which assumptions have been validated vs. just believed?

**Seed questions**:
- What are you assuming about the environment, users, data, or infrastructure that might not hold?
- Which of your constraints are truly immovable vs. negotiable with the right effort?
- If you had to defend every assumption to a skeptic, which ones would be hardest to justify?
- What has changed recently that might invalidate a previously safe assumption?

#### Dependencies & Prerequisites
**What to probe**: External dependencies, sequencing, blocking conditions.

**Skeptical angles**:
- What happens if a dependency is delayed, changed, or removed?
- Are there circular dependencies hiding in the plan?
- Is something being assumed as "already done" that actually isn't?

**Seed questions**:
- What must be true/complete/available before this work can begin?
- What other teams, systems, or processes does this depend on? Have they committed?
- What is the critical path? What happens if the longest-lead dependency slips?
- Are there dependencies you haven't listed because they feel obvious?

#### Risks & Failure Modes
**What to probe**: What can go wrong, probability and impact, mitigation plans.

**Skeptical angles**:
- Are the listed risks the real risks, or the comfortable-to-list ones?
- Are mitigations concrete and actionable, or hand-wavy?
- What's the worst-case scenario nobody wants to talk about?

**Seed questions**:
- What is the single most likely way this fails? What about the most catastrophic?
- For each risk, what is the early warning signal? How would you detect it?
- What happens if this succeeds in ways you didn't expect? (Positive risks / scaling challenges)
- Is there a risk you've been avoiding thinking about?

#### Stakeholders & Audience
**What to probe**: Who cares, who decides, who executes, who is affected.

**Skeptical angles**:
- Is anyone affected who hasn't been consulted?
- Are the people who must execute this the same ones who designed it?
- Could stakeholder interests conflict?

**Seed questions**:
- Who has veto power over this? Whose buy-in is required?
- Who will build/execute this? Do they have the skills and capacity?
- Who will be affected but has no voice in this spec? Should they?
- If this goes wrong, who bears the consequences?

---

### Software / Architecture Dimensions

#### Architecture & Design
**What to probe**: Component boundaries, data flow, key abstractions, scalability approach.

**Seed questions**:
- Why this architecture over alternatives? What tradeoffs are you making?
- Where are the boundaries between components? What crosses those boundaries?
- What is the hardest part of this system to change later?
- How does this scale? At what point does the architecture break down?

#### Data Model
**What to probe**: Entities, relationships, consistency, migration, storage lifecycle.

**Seed questions**:
- What are the core entities? How do they relate to each other?
- What consistency guarantees are needed? Strong, eventual, or none?
- How does the data model handle schema evolution?
- What data needs to be retained? For how long? What's the deletion policy?

#### APIs & Interfaces
**What to probe**: Contracts, versioning, backward compatibility, error semantics.

**Seed questions**:
- What is the contract between the caller and the callee? What can each assume?
- How do you handle breaking changes? What's the versioning strategy?
- What does the error contract look like? How does a consumer distinguish recoverable from fatal errors?
- Who are the consumers of this API? Have they been consulted?

#### Security & Access
**What to probe**: Auth, authz, trust boundaries, data classification, attack surface.

**Seed questions**:
- What is the trust boundary? What is trusted vs. untrusted input?
- How are credentials managed? Where do secrets live?
- What data is sensitive? How is it classified and protected?
- If an attacker compromised this component, what would they be able to do?

#### Operations & Observability
**What to probe**: Deployment, monitoring, alerting, incident response, runbooks.

**Seed questions**:
- How do you know this system is healthy? What are the key health signals?
- What does the deployment process look like? Can you roll back safely?
- When this system pages you at 3am, what do you do? Is there a runbook?
- What failure modes are not covered by monitoring?

---

### Product Requirements Dimensions

#### User Personas & Jobs-to-be-Done
**What to probe**: User segmentation, motivations, pain points, alternatives.

**Seed questions**:
- Who is the primary user? What are they trying to accomplish, and why?
- What do users do today without this product? What's their current workaround?
- Are there user segments with conflicting needs? How do you prioritize?
- What would make a user stop using this?

#### User Journeys & Workflows
**What to probe**: Step-by-step flows, branching, error states, edge cases.

**Seed questions**:
- Walk me through the happy path end-to-end. What does each step feel like?
- Where can the journey go wrong? What does the user see when it does?
- Are there alternative paths? What about first-time vs. repeat users?
- What is the most confusing or frustrating step? How do you know?

#### Acceptance Criteria
**What to probe**: Testability, specificity, completeness.

**Seed questions**:
- For each requirement, how would a QA engineer verify it's met?
- Are there requirements that sound clear but are actually ambiguous when you try to test them?
- What edge cases aren't covered by the acceptance criteria?
- Could someone implement this differently than you envision and still pass all criteria?

#### Prioritization & Sequencing
**What to probe**: Must-have vs. nice-to-have, phasing, cut criteria.

**Seed questions**:
- If you could only ship three features, which three?
- What's the minimum viable version that delivers value?
- What's your "cut line" — the criteria for dropping a feature from this release?
- Are there dependencies between features that constrain sequencing?

#### Metrics & Analytics
**What to probe**: KPIs, instrumentation, success thresholds, counter-metrics.

**Seed questions**:
- How will you know this succeeded? What's the leading indicator vs. lagging?
- What's the counter-metric — what should NOT get worse?
- Do you have a baseline for the metrics? Where does it come from?
- How long after launch until you can measure success?

---

### Scientific Inquiry Dimensions

#### Hypotheses & Predictions
**What to probe**: Specificity, testability, directional predictions.

**Seed questions**:
- Is the hypothesis specific enough to be falsifiable?
- What result would disprove the hypothesis? Would you actually accept that result?
- Are there competing hypotheses that could explain the same observation?
- What is the expected effect size? Where does that expectation come from?

#### Methodology & Design
**What to probe**: Design appropriateness, control conditions, randomization.

**Seed questions**:
- Why this study design over alternatives? What's the tradeoff?
- What is the unit of analysis? Is it the right one?
- How is randomization performed? At what level?
- What are the control conditions? Are they adequate?

#### Variables & Measurement
**What to probe**: Operationalization, reliability, construct validity.

**Seed questions**:
- How exactly is each variable measured? Could two researchers measure it differently?
- Is your measure capturing the construct you care about, or a proxy?
- What's the measurement error? How does it affect your conclusions?
- Are there variables you should measure but aren't? (Mediators, moderators, confounds.)

#### Data Collection & Analysis Plan
**What to probe**: Sample size adequacy, collection protocol, statistical methods.

**Seed questions**:
- How did you determine the sample size? Show me the power analysis.
- What happens if the data collection protocol is violated? How do you detect it?
- What statistical test will you use? Why that one? What are its assumptions?
- How do you handle missing data? What if missingness is not random?

#### Validity Threats
**What to probe**: Confounds, selection bias, maturation, history effects.

**Seed questions**:
- What confounds could produce the same observed effect without the hypothesized mechanism?
- How do you rule out selection bias? Survivorship bias?
- If this study were run at a different time or place, would results hold?
- What would a skeptic say is the biggest flaw in this design?

#### Ethical Considerations
**What to probe**: IRB, consent, harm, data privacy.

**Seed questions**:
- Does this study need ethics review? Has it been obtained?
- Could this study cause harm to participants? Even subtle or indirect harm?
- How is personally identifiable information handled?
- Are participants (or data subjects) informed? Can they opt out?

---

### Agentic Tools / AI Systems Dimensions

#### Agent Capabilities & Boundaries
**What to probe**: What it can do, what it must not do, how limits are enforced.

**Seed questions**:
- What are the explicit limits of what this agent can do? How are they enforced?
- What happens when the agent encounters a task outside its capabilities?
- Could the agent's capabilities be misused? By the user? By adversarial input?
- What's the worst thing this agent could do if it malfunctioned?

#### Interaction Model
**What to probe**: Human-in-the-loop, autonomy level, escalation.

**Seed questions**:
- At what points must a human intervene? What triggers escalation?
- How does the agent communicate uncertainty to the user?
- What happens if the user doesn't respond to a question? Does the agent proceed or block?
- Is the level of autonomy appropriate for the risk level of the tasks?

#### Prompt & Instruction Design
**What to probe**: System prompt clarity, behavioral guardrails, edge case handling.

**Seed questions**:
- If you gave the system prompt to a new engineer, could they predict the agent's behavior?
- Are there scenarios where the instructions are ambiguous or contradictory?
- How does the agent handle requests that are adjacent to but outside its instructions?
- What instructions are most likely to be ignored under pressure (long context, complex tasks)?

#### Safety & Guardrails
**What to probe**: Failure containment, hallucination, scope creep, adversarial robustness.

**Seed questions**:
- What's the blast radius if the agent makes a mistake? How is it contained?
- How does the agent avoid hallucinating facts? Is there a citation or grounding requirement?
- Can the agent be tricked into operating outside its intended scope?
- What's the recovery path when the agent produces incorrect output?

#### Evaluation & Testing
**What to probe**: Test coverage, regression detection, success measurement.

**Seed questions**:
- How do you test that the agent behaves correctly? What are the test cases?
- How do you detect regression — when a change breaks previously working behavior?
- What does "correct behavior" even mean for this agent? How is it defined?
- Can you evaluate the agent without human judgment, or is human eval required?

---

### General Dimensions

#### Process & Workflow
**What to probe**: Steps, decision points, handoffs, approval gates.

**Seed questions**:
- Walk me through the process end-to-end. Where are the decision points?
- Who is responsible at each step? Where does responsibility transfer?
- What happens when the process stalls? What's the escalation path?
- Are there steps that could be parallelized or eliminated?

#### Definitions & Terminology
**What to probe**: Ambiguous terms, jargon, assumed knowledge.

**Seed questions**:
- Are there terms in this spec that different readers might interpret differently?
- Is there jargon that needs to be defined for the target audience?
- Are there implicit definitions that should be made explicit?

#### Compliance & Governance
**What to probe**: Regulatory requirements, policy constraints, approval processes.

**Seed questions**:
- What laws, regulations, or organizational policies apply to this work?
- Who has approval authority? What's the approval process?
- Are there audit or reporting requirements?
- What happens if compliance requirements change after work begins?
