# Troubleshooting

## `$single-luna-orchestrator` is not recognized

1. Verify the skill exists under `$CODEX_HOME/skills/single-luna-orchestrator` (or
   `~/.codex/skills/single-luna-orchestrator`).
2. Fully restart Codex and start a new session.
3. Type the canonical lowercase token manually:

```text
$single-luna-orchestrator
```

The skill is explicit-only; do not expect background or implicit activation.

## The designated child is not in `list_agents`

Do not infer that the child is gone. `list_agents` visibility is observational, not
authoritative, and an idle retained target may be hidden.

Before any spawn or replacement decision, send the same canonical target
`/root/single_luna_executor` a no-op `RECOVERY_PROBE` with `followup_task`:

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

Use the following decision matrix:

| Recovery result | Required action |
| --- | --- |
| `STATUS: SINGLE_LUNA_REATTACHED` | Treat as `ACTIVE_USABLE`; reuse the same target with `followup_task`, even if hidden. |
| Definitive target/thread/path not found, and the child existed earlier | Report `STATUS: SINGLE_LUNA_SESSION_STALE`; do not replace; start a new Codex session. |
| Definitive not-found, demonstrably fresh lifecycle | The only initial spawn may proceed after explicit invocation and authorization. |
| Timeout, transport failure, missing completion, or other ambiguous error | Fail closed: no spawn, no replacement, retry later or start a new session. |

If freshness is uncertain, do not guess and do not spawn.

## A second child appears

Stop the workflow and report the conflict. Single-Luna permits exactly one native child:

```text
/root/single_luna_executor
```

Never create `_2`, `_recovery`, `_new`, or any explorer/planner/tester/verifier/auditor/
reviewer/fixer/nested child. Do not raise the concurrency limit to work around visibility.

## Child model is not Luna / Max

Stop implementation. The expected child is GPT-5.6 Luna at reasoning effort `max`. If the
runtime does not expose spawn-time overrides, use only the documented native `[agents]`
defaults. Do not silently substitute another model or create a replacement.

## Plan Mode spawned a child before approval

That is a failure. While `ARMED` and planning, child count must remain zero and
`spawn_agent` must not be called. Start a fresh session before retrying if the lifecycle is
unclear.

## Recovery probe itself is unavailable

Treat timeouts, transport errors, and missing completion notifications as ambiguous. Fail
closed: do not spawn or replace the target. Retry later or start a new session. Only an
explicit target/thread/path not-found result can enter the freshness decision.

## Runtime has no `close_agent`

This is supported. Call `list_agents`, report visibility, stop assigning implementation work,
and report:

```text
SESSION_COMPLETE
```

Do not use `interrupt_agent` as a fake close, claim clean `DISABLED`, or spawn a replacement.
A new Codex session is required for clean `DISABLED` or an unrelated task.

## Installer concerns

The default installer:

- installs the managed skill;
- merges only the marked block into `AGENTS.md`;
- backs up files before changing them;
- leaves `config.toml` unchanged;
- does not read, write, or modify `hooks.json`.

Strict mode additionally merges the five documented native-agent settings and creates a
timestamped `config.toml` backup first. It does not copy personal paths, project trust, MCP,
plugin, notification, or credential settings.
