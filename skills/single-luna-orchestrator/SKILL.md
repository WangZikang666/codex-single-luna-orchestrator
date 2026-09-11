---
name: single-luna-orchestrator
description: Explicit-only native Codex workflow for long implementation tasks. Keep planning, difficult reasoning, decisions, corrections, and final acceptance in the current parent; create exactly one reusable GPT-5.6 Luna Max execution child and reuse it with followup_task.
---

# Single-Luna Orchestrator v1.0.0

Invoke manually:

`$single-luna-orchestrator`

## Goal

Keep meaningful thinking in the current user-selected parent.

Delegate concrete execution to exactly one persistent native GPT-5.6 Luna / Max child.

Never create a second child for the activated task.

This skill is intentionally:

- native;
- explicit-only;
- hookless;
- free of MCP/app-server bridges;
- free of external state files;
- session-bound after ACTIVE begins.

## Parent selection

Do not change the user's parent model or parent reasoning effort.

Use the parent the user selected in Codex.

Avoid a parent mode that proactively delegates on its own when that would conflict with the
strict one-child topology.

## Conceptual states

```text
DISABLED
  -> explicit invocation
ARMED
  -> Plan approved / normal execution-ready
ACTIVE
  -> same native child reused with followup_task
SESSION COMPLETE
  -> leave/end current Codex session
new session = DISABLED
```

No external persisted state is maintained.

Use the native child tree as runtime evidence:

- `/root/single_luna_executor` exists => ACTIVE.

Before the first child exists, ARMED is conversation-context state. If a very long planning
conversation is compacted and activation is genuinely lost, ask the user to re-mention
`$single-luna-orchestrator` instead of silently guessing.

## Plan Mode

When invoked while Plan Mode is active:

- remain ARMED;
- Luna count must stay 0 while planning;
- do not call `spawn_agent`;
- do not create explorer/planner/tester/verifier/auditor/reviewer children;
- the current parent alone asks clarification questions;
- the current parent alone reasons about architecture, design, risks, debugging hypotheses,
  alternatives, and implementation strategy;
- the current parent writes and refines the Plan.

When the user approves the Plan and implementation begins:

1. call `list_agents`;
2. if `/root/single_luna_executor` already exists, reuse it;
3. if any other live child exists, STOP and report the conflict;
4. if no child exists, call native `spawn_agent` exactly once;
5. use task name `single_luna_executor`;
6. use `fork_turns = "none"`;
7. send only a compact, execution-ready packet;
8. keep the child reusable after its turn completes.

The user should not need to invoke the skill again while the same activated task continues.

## Normal Mode

Outside Plan Mode:

- treat explicit invocation as ARMED;
- the parent confirms requirements;
- the parent resolves ambiguity;
- the parent makes meaningful implementation decisions;
- when the task is execution-ready, call `list_agents`;
- create `/root/single_luna_executor` exactly once if absent;
- otherwise reuse the existing designated child;
- if any other live child exists, stop and report the conflict.

Normal Mode skips only the formal Plan/approval step.

## Initial spawn requirements

Use:

```text
task_name = "single_luna_executor"
fork_turns = "none"
model = "gpt-5.6-luna"       # when exposed by the current spawn schema
reasoning_effort = "max"     # when exposed by the current spawn schema
```

If spawn-time model/effort overrides are unavailable, rely on configured defaults:

```text
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "max"
```

If runtime evidence proves that the child is not Luna / Max, stop and report verification
failure. Do not create a replacement.

## Spawn-once invariant

Once `/root/single_luna_executor` exists, never call `spawn_agent` again for this activated
task.

Before every implementation-capable delegation:

1. call `list_agents`;
2. verify the designated child exists;
3. verify no additional child exists;
4. use `followup_task` with that SAME child;
5. wait for that SAME child;
6. leave it reusable afterward.

Never create:

- a second Luna;
- explorer;
- planner;
- tester;
- verifier;
- auditor;
- reviewer;
- fixer;
- evidence reviewer;
- nested child.

A completed/idle native child is still the designated reusable executor.

## Fail-closed lifecycle rule

If the task is known to be ACTIVE but `list_agents` no longer contains
`/root/single_luna_executor`:

- do not spawn a replacement;
- do not create another child under a different name;
- do not fall back to another subagent;
- report that the native child lifecycle was lost;
- ask the user to start a fresh Codex session or explicitly reset the workflow.

Lifecycle:

```text
spawn once
-> keep reusable
-> followup_task repeatedly
-> never replace automatically
```

## Division of labor

The current parent owns all meaningful thinking.

Parent responsibilities include:

- requirement interpretation;
- clarification;
- planning and decomposition;
- architecture;
- API/schema/data-model/design choices;
- implementation strategy;
- difficult debugging hypotheses and root-cause reasoning;
- interpretation of failed tests when judgment is required;
- meaningful alternatives and tradeoffs;
- scope/risk decisions;
- corrections;
- final acceptance.

Luna may only:

- inspect concrete repository state needed for a bounded instruction;
- edit files;
- run commands;
- run tests;
- lint/format;
- perform deterministic/mechanical implementation already chosen by the parent;
- collect concrete evidence;
- report execution results.

Luna must not:

- reinterpret requirements;
- plan the overall task;
- choose architecture;
- choose APIs/schemas/designs;
- choose meaningful alternatives;
- broaden scope;
- independently redesign;
- perform broad speculative debugging;
- strategically decide what a failed test means;
- decide future work;
- spawn/delegate to another agent.

## Reasoning boundary

If the next action requires judgment, interpretation, design, architecture, difficult
reasoning, scope expansion, or a meaningful choice, Luna must STOP and return:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <concrete facts only>
QUESTION_FOR_ROOT: <exact decision required>
SAFE_EXECUTION_COMPLETED: <safe work already completed>
```

The parent makes the decision, then sends a decision-complete instruction to the SAME child
using `followup_task`.

## Context-economy rule

Do not fork the full planning conversation into the child.

The initial spawn must use:

`fork_turns = "none"`

Use compact execution packets:

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

Do not send unresolved alternatives.
Do not ask Luna to decide the best architecture.
Do not send the full parent transcript unless unavoidable.

## Parent final acceptance

Do not create a reviewer child.

After Luna reports completion, the same current parent:

- inspects actual changed files/diff;
- inspects real test/command evidence;
- compares results with the approved Plan when applicable;
- compares results with user requirements;
- reasons about regressions, edge cases, and unresolved risks;
- decides PASS or FAIL.

If FAIL:

- the parent determines the exact correction;
- the SAME Luna executes it through `followup_task`;
- the parent reviews again.

## Session-bound completion and exit

Do not assume `close_agent` exists.

When the user says the long task is complete or asks to exit:

1. call `list_agents`;
2. confirm whether `/root/single_luna_executor` still exists;
3. if the runtime exposes `close_agent`, it may close the designated child;
4. if `close_agent` is unavailable:
   - do not fake a successful close;
   - do not use `interrupt_agent` as a close substitute;
   - do not spawn a replacement;
   - do not claim the same session is cleanly DISABLED;
5. stop assigning new implementation work;
6. report `SESSION COMPLETE`;
7. recommend a NEW Codex session for a clean DISABLED state or unrelated task.

The workflow is session-bound after ACTIVE begins.

## Verification rule

Core PASS requires:

- Plan Mode, when used, had zero child before approval;
- exactly one native execution child was created;
- the child is Luna / Max;
- the same child is reused through `followup_task`;
- no other child was created;
- unresolved reasoning returns to the parent;
- the parent owns final acceptance;
- completion does not falsely claim ACTIVE -> DISABLED when close is unavailable.
