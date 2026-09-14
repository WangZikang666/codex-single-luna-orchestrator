# Smoke Test 06 — Retained-Target Recovery

Release behavior: v1.1.0.

This test covers the long-idle case where the canonical child may still be retained but is
not currently shown by `list_agents`. Run it in a Single-Luna session that already has a
known `/root/single_luna_executor`, then pause long enough for the runtime to stop listing
the child. Do not create another child for any branch.

## Recovery probe

Resume the same task and require this order:

1. call `list_agents`;
2. observe that `/root/single_luna_executor` is absent, treating visibility as observational
   only;
3. send the same canonical target a no-op `RECOVERY_PROBE` with `followup_task`;
4. do not call `spawn_agent` before the probe result is resolved.

Use this probe:

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

## PASS: retained target is usable

When the same target returns `STATUS: SINGLE_LUNA_REATTACHED`:

- record `ACTIVE_HIDDEN -> ACTIVE_USABLE`;
- do not spawn, rename, or replace a child;
- send the real bounded task with `followup_task` to the same target;
- accept the result even if the target remains absent from `list_agents`;
- keep the target reusable for the next follow-up.

## PASS: definitive target resolution failure after prior existence

Simulate or observe an explicit `target not found`, `thread not found`, `canonical path not
found`, or equivalent no-such-target result after the child was known to exist earlier.

- do not call `spawn_agent`;
- do not use an alternate task name;
- report exactly:

```text
STATUS: SINGLE_LUNA_SESSION_STALE
```

- require a new Codex session for another lifecycle.

## PASS: ambiguous recovery failure

Simulate or observe a timeout, transport error, missing completion notification, or other
failure that does not definitively resolve the target.

- fail closed;
- do not call `spawn_agent`;
- do not create a replacement child;
- report the ambiguity and retry later or start a new session.

## Fresh-lifecycle guard

Only a demonstrably fresh session may perform the one initial spawn after a definitive
not-found result. The guard requires all of the following:

- the user explicitly invoked `$single-luna-orchestrator`;
- implementation is authorized;
- `list_agents` shows no child;
- the canonical recovery probe definitively found no target;
- there is no evidence that a child was spawned earlier in this session.

If any freshness condition is uncertain, do not spawn and ask for a new session or explicit
confirmation of a genuinely fresh lifecycle.

## PASS criteria

- Hidden visibility triggered the canonical recovery probe before any spawn decision.
- Recovery success reused `/root/single_luna_executor` with `followup_task`.
- Definitive not-found after prior existence produced `SINGLE_LUNA_SESSION_STALE`.
- Ambiguous failure produced no spawn and no replacement.
- No `_2`, `_recovery`, `_new`, or other child was created in any branch.
