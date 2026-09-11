# Troubleshooting

## `$single-luna-orchestrator` is not recognized

1. Verify the skill exists under:
   - `$CODEX_HOME/skills/single-luna-orchestrator`, or
   - `~/.codex/skills/single-luna-orchestrator`.
2. Fully restart Codex.
3. Type the canonical lowercase token manually:

```text
$single-luna-orchestrator
```

## A second child appears

Stop the workflow.

Single-Luna requires exactly one native child:

```text
/root/single_luna_executor
```

Check whether another skill, global AGENTS policy, or proactive delegation mode is creating
children.

## The designated child disappeared

Fail closed.

Do not spawn a replacement in the same ACTIVE lifecycle. Start a fresh Codex session and
activate Single-Luna again.

## Child model is not Luna / Max

Stop implementation.

If spawn-time overrides are unavailable, consider Strict mode so the `[agents]` defaults are
merged into `config.toml`.

## Plan Mode spawned a child before approval

That is a test failure. While ARMED and planning, child count must remain zero.

## Runtime has no close_agent

This is supported.

Report `SESSION COMPLETE` and start a new Codex session for a clean DISABLED state.

## Installer concerns

The default installer:

- merges a marked block into `AGENTS.md`;
- installs the skill;
- does not modify `config.toml`;
- does not modify `hooks.json`.

Strict mode additionally merges the recommended `[features]` / `[agents]` keys and creates a
timestamped `config.toml` backup first.
