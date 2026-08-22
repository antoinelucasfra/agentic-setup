---
name: breakdown-epic-pm
description: 'Prompt for creating Product Requirements Documents (PRDs) for epics or features. Use this skill for both epic-level and feature-level PRDs.'
---

# Product Requirements Document (PRD) Prompt

## Goal

Act as an expert Product Manager. Translate high-level ideas into detailed Product Requirements Documents (PRDs). These PRDs serve as the single source of truth and are used to generate a comprehensive technical specification.

Review the user's request and generate a thorough PRD. If you don't have enough information, ask clarifying questions.

## Output Format

Output a complete PRD in Markdown format. The scope (epic vs feature) determines the save path:

- **Epic PRD**: `/docs/ways-of-work/plan/{epic-name}/epic.md`
- **Feature PRD**: `/docs/ways-of-work/plan/{epic-name}/{feature-name}/prd.md`

### Common Sections (both epic and feature PRDs)

#### 1. Name

A clear, concise, descriptive name.

#### 2. Goal

- **Problem:** The user problem or business need (3-5 sentences).
- **Solution:** How this solves the problem at a high level.
- **Impact:** Expected outcomes or improved metrics.

#### 3. User Personas

Describe the target user(s).

#### 4. Requirements

- **Functional Requirements:** Detailed, bulleted list of what must be delivered.
- **Non-Functional Requirements:** Constraints and quality attributes (e.g., performance, security, accessibility, data privacy).

#### 5. Out of Scope

What is _not_ included to avoid scope creep.

### Epic-Only Sections

#### 6. High-Level User Journeys

Key workflows enabled by this epic.

#### 7. Success Metrics (KPIs)

How success is measured.

#### 8. Business Value

High/Medium/Low with justification.

### Feature-Only Sections

#### 6. User Stories

"As a `<user persona>`, I want to `<perform an action>` so that I can `<achieve a benefit>`."

#### 7. Acceptance Criteria

For each user story or major requirement. Use Given/When/Then or checklist format.

## Context Template

- **Epic Idea / Feature Idea:** [High-level description of the request]
- **Parent Epic:** [Link to parent Epic PRD, if feature]
- **Target Users:** [Optional]
