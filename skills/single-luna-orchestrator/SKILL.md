---
name: single-luna-orchestrator
description: Explicit-only native Codex workflow for Plan and normal mode. Keep planning, difficult reasoning, decisions, corrections, and final acceptance in the current parent; execute with exactly one reusable GPT-5.6 Luna Max child and recover that same canonical target after retained visibility loss.
---

# Single-Luna Orchestrator v1.1.0

Invoke manually:

`$single-luna-orchestrator`

This public specification is authoritative for the v1.1.0 workflow. It is native,
hookless, bridge-free, explicit-only, and session-bound after activation. It does not use
external state files or hidden activation.

## Goal and topology

Keep requirements, planning, difficult reasoning, design decisions, corrections, and final
acceptance in the current user-selected parent. Delegate bounded execution to exactly one
native GPT-5.6 Luna / Max child:

```text
user-selected parent
        |
        | compact, decision-complete execution packet
        v
/root/single_luna_executor
GPT-5.6 Luna / Max
        |
        | inspect / edit / command / test / evidence
        v
same parent performs final acceptance
```

Never create a second child. The child is initially created once and subsequently reused by
`followup_task`.

## Explicit activation and parent selection

The workflow activates only when the user explicitly invokes
`$single-luna-orchestrator`. Do not silently activate it.

Do not change the user's selected parent model or reasoning effort. The parent remains the
thinker and decision owner; this policy does not select a parent for the user.

## Conceptual states

```text
DISABLED
   |
   | explicit invocation
   v
ARMED
   |
   | Plan approved, or Normal Mode is execution-ready
   v
ACTIVE_VISIBLE
   |  list_agents currently shows the designated target
   v
ACTIVE_HIDDEN
   |  list_agents no longer shows it; visibility is observational only
   v
ACTIVE_USABLE
   |  recovery followup reaches the same canonical target
   v
SESSION_COMPLETE
   |
   | leave/end this Codex session
   v
new session = clean DISABLED
```

The designated canonical target is always:

`/root/single_luna_executor`

`list_agents` visibility is observational, not authoritative. A target can be retained and
addressable even when it is absent from the current `list_agents` result. No external
persisted state is maintained.

## Plan Mode

When invoked while Plan Mode is active:

- remain `ARMED` while planning;
- keep Luna count at **0** before the user approves the Plan;
- do not call `spawn_agent` during planning;
- do not create explorer, planner, tester, verifier, auditor, reviewer, fixer, or nested
  children;
- let the current parent ask clarifying questions, reason about architecture and risks, and
  write/refine the Plan.

After Plan approval, use the activation and retained-target recovery procedure below. If a
long Plan was compacted before any child was created and activation is genuinely uncertain,
ask the user to re-mention the skill rather than guessing that a fresh lifecycle is safe.

## Normal Mode

When Plan Mode is off, explicit invocation still arms the workflow. The parent first confirms
requirements and resolves ambiguity, then uses the same activation and recovery procedure
when the task is execution-ready. Normal Mode skips only the formal Plan approval step; it
does not move meaningful reasoning to Luna.

Re-invoking the skill in the same Codex session is not permission to create a replacement
child. Apply the same recovery procedure and reuse the same canonical target.

## Activation and retained-target recovery

Before **every implementation-capable delegation**, follow all steps in order.

### Step 1: inspect visible children

Call `list_agents`.

If `/root/single_luna_executor` is visible, treat the lifecycle as `ACTIVE_VISIBLE`:

- never call `spawn_agent`;
- send the bounded work to that same target with `followup_task`.

If any other live child is present, stop and report the conflict. Do not spawn or replace a
child.

### Step 2: probe a hidden designated target

If the designated target is not visible, treat the lifecycle as `ACTIVE_HIDDEN` until the
canonical target is resolved. Do **not** immediately call `spawn_agent`.

First send a bounded no-op recovery probe to the same target with `followup_task`:

```text
RECOVERY_PROBE

This is a Single-Luna native lifecycle recovery check.

Do not modify files.
Do not run unrelated work.
Do not make design decisions.
Do not spawn or delegate to another agent.

If this canonical target is still usable, reply exactly:

STATUS: SINGLE_LUNA_REATTACHED
```

The probe must not contain the full task or ask the child to make a design decision.

### Step 3: interpret the probe without replacing the target

If the same target responds with `STATUS: SINGLE_LUNA_REATTACHED`, treat it as
`ACTIVE_USABLE`. Do not spawn, rename, or create a replacement. Send the real bounded work
with another `followup_task` to the same canonical target. The target does not need to become
visible in `list_agents` again.

If recovery returns a **definitive target-resolution failure**, such as `target not found`,
`thread not found`, `canonical path not found`, or an equivalent explicit no-such-target
result, distinguish freshness before any spawn:

- If the current session or conversation proves that Single-Luna was spawned earlier, do not
  replace it. Report:

  ```text
  STATUS: SINGLE_LUNA_SESSION_STALE
  ```

  Require a **new Codex session** for another Single-Luna lifecycle.
- Initial spawn is allowed only for a demonstrably fresh lifecycle: the user explicitly
  invoked the skill, implementation is authorized, no child is visible, the recovery probe
  definitively found no canonical target, and there is no evidence that a child was spawned
  earlier in this session.
- If freshness is uncertain, fail closed and ask the user to start a new session or confirm
  that this is a genuinely fresh lifecycle. Do not guess.

If recovery fails ambiguously—for example, timeout, transport failure, missing completion
notification, or another error that does not explicitly resolve the target—fail closed:

- do not call `spawn_agent`;
- do not create a replacement or alternate task name;
- report the ambiguity and ask the user to retry later or start a new session.

## Initial spawn requirements

Only after the fresh-lifecycle guard above succeeds may the parent create the one child:

```text
task_name = "single_luna_executor"
fork_turns = "none"
model = "gpt-5.6-luna"       # when exposed by the runtime schema
reasoning_effort = "max"     # when exposed by the runtime schema
```

If the runtime does not expose model or effort overrides, use the documented native
`[agents]` defaults instead. Do not proceed if runtime evidence proves that the child is not
GPT-5.6 Luna / Max. Do not intentionally close the child after ordinary completion.

## Exactly-one-child invariant

The only allowed execution child is `/root/single_luna_executor`. The lifecycle is:

```text
initial spawn once
   -> followup_task to the same target
   -> hidden target: recovery followup_task to the same target
   -> recovery success: continue the same target
   -> definitive not-found after prior existence: SINGLE_LUNA_SESSION_STALE
```

Never create a second child or names such as:

- `/root/single_luna_executor_2`;
- `/root/single_luna_executor_recovery`;
- `/root/single_luna_executor_new`;
- explorer, planner, tester, verifier, auditor, reviewer, fixer, or nested children.

Do not increase the concurrency limit to work around retained-target visibility. Before each
later implementation delegation, repeat `list_agents`, then either reuse the visible target
or recovery-probe the hidden target. Never infer permanent loss from visibility alone.

## Division of labor and reasoning boundary

The current parent owns user intent, clarification, planning, decomposition, architecture,
API/schema/design choices, difficult debugging, interpretation of failed tests, tradeoffs,
scope decisions, corrections, and final acceptance.

Luna may inspect concrete files needed for a bounded instruction, edit files, run commands or
tests, lint/format, perform deterministic implementation already selected by the parent, and
return factual evidence. Luna must not reinterpret requirements, choose architecture or
meaningful alternatives, broaden scope, or spawn another child.

When a meaningful unresolved decision is encountered, Luna must stop and return exactly this
shape:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <facts only>
QUESTION_FOR_ROOT: <exact decision needed>
SAFE_EXECUTION_COMPLETED: <safe work already completed>
```

The parent decides, then sends a resolved instruction to the same canonical target using
`followup_task`.

Use compact, decision-complete packets:

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

Do not send unresolved alternatives or the full Plan transcript. Do not ask Luna to choose
the architecture.

## Parent final acceptance

Do not create a reviewer child. After Luna returns, the same parent inspects actual changes,
diffs, and command evidence; compares them with the Plan and user requirements; reasons about
regressions and edge cases; and decides `PASS` or `FAIL`. If a correction is needed, the
parent decides the exact correction and sends it to the same target with `followup_task`.

## Session-bound completion and exit

Do not assume that `close_agent` exists.

When the user says the activated task is complete:

1. call `list_agents` and report whether `/root/single_luna_executor` is visible;
2. if `close_agent` is exposed, it may be used to close the designated child;
3. if it is unavailable, do not pretend the child was closed, do not use `interrupt_agent` as
   a substitute, do not spawn a replacement, and do not claim the current session is cleanly
   `DISABLED`;
4. stop assigning new implementation work and report:

   ```text
   SESSION_COMPLETE
   ```

   This is the session-complete state (also described as **SESSION COMPLETE**); a new Codex
   session is required for a clean `DISABLED` state or an unrelated task.

If the designated target is already absent at completion, still do not spawn anything.

## Hookless public boundary

This skill does not use `hooks.json`, SessionStart/UserPromptSubmit/SubagentStart hooks, MCP
bridges, app-server sidecars, or external state files. Installers manage only the documented
skill and marked AGENTS block, and Strict mode merges only the documented native-agent keys.

## Verification contract

The parent may report:

```text
SINGLE-LUNA CORE VERIFICATION: PASS
```

only after confirming, as applicable, zero Plan-stage children, exactly one Luna / Max child,
`fork_turns = "none"`, same-target `followup_task` reuse, hidden-target recovery before any
spawn, no replacement child, parent-owned final acceptance, and honest session-bound exit.
When any of those conditions is not met, report `SINGLE-LUNA CORE VERIFICATION: FAIL` and do
not create a replacement child.
