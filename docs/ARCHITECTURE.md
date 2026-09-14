# Architecture

## Objective

Single-Luna Orchestrator v1.1.0 separates decision ownership from execution ownership while
preserving one native child across long or idle sessions.

```text
Parent
  ├─ requirements and clarification
  ├─ Plan / architecture / difficult reasoning
  ├─ decisions and corrections
  └─ final acceptance
          |
          | compact, decision-complete packet
          v
/root/single_luna_executor
  ├─ concrete inspection
  ├─ edits and commands
  ├─ tests / lint / format
  └─ factual evidence
```

The child is GPT-5.6 Luna / Max. The parent never delegates meaningful unresolved choices to
it, and no reviewer or other specialist child is created.

## Lifecycle and recovery

```text
DISABLED
   -> explicit invocation
ARMED
   -> Plan approval or execution-ready Normal Mode
ACTIVE_VISIBLE
   -> list_agents shows /root/single_luna_executor
ACTIVE_HIDDEN
   -> list_agents no longer shows it; visibility is observational only
ACTIVE_USABLE
   -> recovery followup reaches the same target
SESSION_COMPLETE
   -> new session for clean DISABLED
```

The canonical target is always `/root/single_luna_executor`. Before every
implementation-capable delegation, the parent calls `list_agents`. A visible target is
reused with `followup_task`. A hidden target is not assumed lost: the parent sends a
no-op `RECOVERY_PROBE` to the same target with `followup_task`.

The successful probe response is:

```text
STATUS: SINGLE_LUNA_REATTACHED
```

That response transitions the lifecycle to `ACTIVE_USABLE`; the same target receives the
real bounded work even if it remains absent from `list_agents`.

If the probe definitively returns target/thread/canonical-path not found, the parent checks
freshness. A previously existing target produces:

```text
STATUS: SINGLE_LUNA_SESSION_STALE
```

and requires a new Codex session. Initial spawn is permitted only when the user explicitly
invoked the skill, implementation is authorized, no child is visible, the probe definitively
found no target, and there is no evidence of an earlier child in this session. If freshness
is uncertain, or the probe fails ambiguously (timeout, transport failure, or missing
completion), the parent fails closed without spawning or replacing a child.

## Spawn and reuse

The one initial spawn uses:

```text
task_name = "single_luna_executor"
fork_turns = "none"
model = "gpt-5.6-luna"
reasoning_effort = "max"
```

When model/effort arguments are unavailable, the documented native `[agents]` defaults are
used. The concurrency setting is not increased to work around retention. No names such as
`/root/single_luna_executor_2`, `/root/single_luna_executor_recovery`, or
`/root/single_luna_executor_new` are valid replacements.

## Reasoning handoff

When Luna encounters an unresolved meaningful choice, it stops and returns:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <facts only>
QUESTION_FOR_ROOT: <decision needed>
SAFE_EXECUTION_COMPLETED: <safe work>
```

The parent makes the decision and sends a resolved packet to the same canonical target with
`followup_task`.

## Final acceptance and exit

The same parent that planned the work inspects the actual files, diff, and test evidence and
decides PASS or FAIL. A reviewer child is not created.

`close_agent` is optional. If it is unavailable, the parent does not fabricate a close or
use `interrupt_agent` as a substitute. It stops assigning work, reports `SESSION_COMPLETE`,
and starts a new Codex session for clean `DISABLED`. An already absent child does not justify
spawning a replacement.

## Hookless boundary

The public workflow does not use `hooks.json`, SessionStart/UserPromptSubmit/SubagentStart
hooks, MCP bridges, app-server sidecars, or external state files. Installers manage only the
skill, the marked AGENTS block, and—when explicitly requested—the documented five native
configuration keys.
