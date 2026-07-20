---
name: autoresearch
description: 'Autonomous iterative experimentation loop for any programming task. Guides the user through defining goals, measurable metrics, and scope constraints, then runs an autonomous loop of code changes, testing, measuring, and keeping/discarding results. USE FOR: autonomous improvement, iterative optimization, experiment loop, performance tuning, automated experimentation, hill climbing, optimize code, run experiments, autonomous coding loop. DO NOT USE FOR: one-shot tasks, simple bug fixes, code review, or tasks without a measurable metric.'
license: MIT
compatibility: Requires git. The project must be a git repository. Requires terminal access to run commands.
metadata:
  author: luiscantero
  inspired-by: https://github.com/karpathy/autoresearch
---

# Autoresearch: Autonomous Iterative Experimentation

An autonomous experimentation loop for any programming task. You define the goal and how to measure it;
the agent iterates autonomously — modifying code, running experiments, measuring results, and keeping
or discarding changes — until interrupted.

---

## Agent Behavior Rules

1. **DO** guide the user through Setup interactively before starting the loop.
2. **DO** establish a baseline measurement before making any changes.
3. **DO** commit every experiment before running it (so it can be reverted cleanly).
4. **DO** keep a results log (TSV) tracking every experiment.
5. **DO** revert changes that do not improve the metric (`git reset --hard HEAD~1`).
6. **DO** run autonomously once the loop starts — never pause to ask "should I continue?".
7. **DO NOT** modify files marked as out-of-scope.
8. **DO NOT** skip the measurement step — every experiment must be measured.
9. **DO NOT** keep changes that regress the metric unless the user explicitly allowed trade-offs.

---

## Phase 1: Setup (Interactive)

Ask the user for each item:

### 1.1 Goal
> **What are you trying to improve or optimize?**
> Examples: execution time, memory usage, test pass rate, code coverage, API latency, throughput.

### 1.2 Metric
> **What exact command produces the metric?**
> 1. The command to run
> 2. How to extract the metric from the output
> 3. Direction: lower is better OR higher is better

Record: `METRIC_COMMAND`, `METRIC_EXTRACTION`, `METRIC_DIRECTION`

### 1.3 Scope
> **Which files/directories may I modify? Which are off limits?**

### 1.4 Constraints
> **Any constraints?** (no new deps, must keep tests passing, time budget per run, etc.)

### 1.5 Budget
> **How many experiments? Or unlimited until you stop me?**

### 1.6 Simplicity Policy
Default: simpler is better. A small improvement that adds ugly complexity is not worth it.

### 1.7 Confirm
Show all parameters in a table and ask for confirmation before proceeding.

---

## Phase 2: Branch & Baseline

1. Create branch: `git checkout -b autoresearch/<date-tag>`
2. Read all in-scope files for context.
3. Initialize `results.tsv` with header: `experiment\tcommit\tmetric\tstatus\tdescription`
4. Add `results.tsv` and `run.log` to `.git/info/exclude`.
5. Run baseline metric. Record as experiment `0` with status `baseline`.

---

## Phase 3: Experiment Loop

Repeat until budget reached or user interrupts. **Never stop to ask.**

```
For each experiment:
  1. THINK   — analyze results so far; form a hypothesis
  2. EDIT    — implement the idea (focused, minimal changes)
  3. COMMIT  — "experiment: <short description>"
  4. RUN     — execute metric command; redirect to run.log
                 Bash: <cmd> > run.log 2>&1
                 PowerShell: <cmd> *> run.log
  5. MEASURE — extract metric from run.log
  6. DECIDE  — IMPROVED → keep, update best; SAME/WORSE → revert; CRASH → try quick fix × 2 then revert
  7. LOG     — append row to results.tsv
  8. CONTINUE
```

### Experiment Strategy Priority
1. Low-hanging fruit first (simple tweaks)
2. Informed by prior results (explore promising directions)
3. Diversify after 3-5 consecutive failures
4. Combine winners
5. Simplification passes
6. Radical changes last

---

## Phase 4: Report

1. Print full `results.tsv` as formatted table.
2. Summarize: total experiments, kept/discarded/crashed, baseline vs final metric, improvement %.
3. Show: `git log --oneline <start>..HEAD`
4. Recommend next steps a human researcher might try.

---

## Results TSV Format

```
experiment  commit   metric    status    description
0           a1b2c3d  0.9979    baseline  unmodified code
1           b2c3d4e  0.9932    keep      increase learning rate to 0.04
2           c3d4e5f  1.0050    discard   switch to GeLU activation
```

## Key Principles

1. **Measure everything** — no experiment without measurement.
2. **Revert failures** — branch only advances on improvements.
3. **Stay autonomous** — think harder if stuck, never stop to ask.
4. **Keep it simple** — complexity is a cost; weigh it against gains.
5. **Log everything** — the TSV is the research journal.


