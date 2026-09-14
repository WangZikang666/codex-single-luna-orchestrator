<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->
## Single-Luna Orchestrator v1.1.0

This block applies only after the user explicitly invokes
`$single-luna-orchestrator`. Never silently activate it. It is native, hookless,
bridge-free, and session-bound after activation; no external state file is used.

### Parent and child contract

- The current parent owns requirements, clarification, Plan, architecture, difficult
  reasoning, decisions, corrections, failed-test interpretation, and final acceptance.
- The only execution child is `/root/single_luna_executor`, using GPT-5.6 Luna / Max.
- Initial spawn uses `fork_turns = "none"`; later work uses `followup_task` to the same child.
- Never create a second, replacement, explorer, planner, tester, verifier, auditor, reviewer,
  fixer, nested, `_2`, `_recovery`, or `_new` child.

### Plan and normal mode

While ARMED and planning, Luna count must be 0 and `spawn_agent` is forbidden. The parent
alone asks questions, makes decisions, and writes the Plan. After Plan approval, or when
Normal Mode is execution-ready, use the recovery-safe activation procedure below.

### Recovery-safe activation

Before every implementation-capable delegation:

1. Call `list_agents`.
2. If `/root/single_luna_executor` is visible (`ACTIVE_VISIBLE`), never spawn; use
   `followup_task` with that same target.
3. If any other live child exists, stop and report the conflict.
4. If the designated target is hidden (`ACTIVE_HIDDEN`), visibility is observational only.
   Do not spawn. Send this no-op probe with `followup_task` to the same canonical target:

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

5. A `STATUS: SINGLE_LUNA_REATTACHED` response means `ACTIVE_USABLE`: reuse the same target
   with another `followup_task`, even if it remains hidden from `list_agents`.
6. A definitive `target not found`, `thread not found`, `canonical path not found`, or
   equivalent no-such-target result requires a freshness check. If the session proves the
   child existed earlier, do not replace it; report
   `STATUS: SINGLE_LUNA_SESSION_STALE` and require a new Codex session. Initial spawn is
   allowed only when the user explicitly invoked the skill, implementation is authorized,
   no child is visible, recovery definitively found no target, and no prior child existence
   is evidenced. If freshness is uncertain, fail closed and do not spawn.
7. A timeout, transport failure, missing completion, or other ambiguous recovery error also
   fails closed: no spawn, no replacement, and retry later or start a new session.

### Reasoning boundary and exit

Luna executes only bounded, decision-complete packets. If a meaningful choice is unresolved,
it must return:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <facts only>
QUESTION_FOR_ROOT: <exact decision needed>
SAFE_EXECUTION_COMPLETED: <safe work already completed>
```

The parent resolves the question and sends the same target a `followup_task`. Do not create a
reviewer child.

Do not assume `close_agent` exists. At completion, call `list_agents` and report visibility.
If `close_agent` is unavailable, do not fake a close, use `interrupt_agent` as a substitute,
claim clean `DISABLED`, or spawn a replacement. Stop assigning work and report
`SESSION_COMPLETE` (SESSION COMPLETE); a new Codex session is required for clean `DISABLED`.
<!-- END SINGLE-LUNA-ORCHESTRATOR -->
