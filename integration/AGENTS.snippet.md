<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->
## Single-Luna Orchestrator continuity policy

This block applies ONLY after the user explicitly invokes:

`$single-luna-orchestrator`

Do not silently activate it.

### State and lifecycle

Conceptual states:

```text
DISABLED -> ARMED -> ACTIVE -> SESSION COMPLETE
```

- ARMED: explicit invocation occurred, but the designated child does not exist yet.
- ACTIVE: `list_agents` shows `/root/single_luna_executor`.
- SESSION COMPLETE: the activated long task is finished. A new Codex session is the clean
  DISABLED state when the runtime cannot explicitly close the child.

The native child tree is the ACTIVE-state source of truth. No external persisted state is
required.

### Plan Mode

While ARMED and still planning:

- child count = 0;
- never call `spawn_agent`;
- the current parent owns clarification, planning, architecture, difficult reasoning, and the
  Plan.

After Plan approval, or when Normal Mode is execution-ready:

1. call `list_agents`;
2. if `/root/single_luna_executor` exists, reuse it;
3. if any other live child exists, stop and report the conflict;
4. if no child exists, native-spawn exactly one child:
   - task name: `single_luna_executor`
   - `fork_turns = "none"`
   - GPT-5.6 Luna / Max when the runtime exposes model/effort selection;
5. keep the designated child reusable after completion.

### Exactly-one-child invariant

Before every later implementation-capable delegation:

1. call `list_agents`;
2. if `/root/single_luna_executor` exists, NEVER call `spawn_agent`;
3. use `followup_task` with that SAME child;
4. never create explorer/planner/tester/verifier/auditor/reviewer/fixer/nested children.

If ACTIVE but the designated child disappears, fail closed. Do not auto-spawn a replacement.

### Division of labor

The current parent owns:

- requirements and clarification;
- planning/decomposition;
- architecture/design/API/schema choices;
- difficult debugging and root-cause reasoning;
- interpretation of failed tests when judgment is needed;
- tradeoffs/corrections;
- final acceptance.

The Luna child owns bounded execution only:

- concrete file inspection needed for the instruction;
- edits;
- commands;
- tests;
- lint/format;
- deterministic/mechanical implementation already selected by the parent;
- factual evidence.

When a meaningful decision is required, Luna must stop and return:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <concrete facts only>
QUESTION_FOR_ROOT: <exact decision required>
SAFE_EXECUTION_COMPLETED: <safe work already completed>
```

The parent decides and sends the resolved instruction to the SAME child.

### Context economy

Never copy the full Plan transcript into Luna. Initial spawn uses `fork_turns = "none"`.

Prefer execution packets:

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

### Final review and exit

Do not create a reviewer child. The same parent performs final acceptance.

Do not assume `close_agent` exists. If it is unavailable, never use `interrupt_agent` as a
fake close. Report `SESSION COMPLETE`, do not spawn a replacement, and use a new Codex session
for a clean DISABLED state.
<!-- END SINGLE-LUNA-ORCHESTRATOR -->
