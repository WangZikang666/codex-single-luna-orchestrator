# Architecture

## Objective

Single-Luna separates **decision ownership** from **execution ownership**.

```text
Parent
  ├─ requirements
  ├─ clarification
  ├─ planning
  ├─ architecture
  ├─ difficult reasoning
  ├─ corrections
  └─ final acceptance
          |
          | compact decision-complete packet
          v
/root/single_luna_executor
  ├─ inspect concrete files
  ├─ edit
  ├─ run commands
  ├─ test
  ├─ lint/format
  └─ return evidence
```

## Lifecycle

```text
DISABLED
  -> explicit invocation
ARMED
  -> Plan approval or execution-ready Normal Mode
ACTIVE
  -> same child reused with followup_task
SESSION COMPLETE
  -> new session for clean DISABLED
```

## Why spawn once?

Repeated child creation wastes context, increases coordination overhead, and can turn a
simple long-running implementation into an expanding agent tree.

Single-Luna instead uses:

```text
spawn once
-> keep reusable
-> followup_task repeatedly
```

## Why fork_turns = none?

The child does not need the full planning transcript. The parent sends only a compact packet:

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

This keeps the worker context focused on execution.

## Reasoning handoff

When Luna encounters a choice that is not already resolved, it stops:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <facts only>
QUESTION_FOR_ROOT: <decision needed>
SAFE_EXECUTION_COMPLETED: <safe work>
```

The parent decides and sends the resolution to the same child.

## No reviewer child

The same parent that made the design decisions performs final acceptance. This avoids paying
for a second high-level reasoning layer and preserves a single source of decision ownership.

## Hookless / bridge-free

v1.0.0 does not use:

- `hooks.json`;
- SessionStart/UserPromptSubmit/SubagentStart hooks;
- MCP bridges;
- app-server sidecars;
- external state files.

ACTIVE state is inferred from the native child tree.
