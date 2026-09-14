# Compatibility

## Validated design target

Public v1.1.0 targets a Codex Desktop Multi-Agent V2 runtime with native operations
equivalent to:

- `list_agents`;
- `spawn_agent`;
- `followup_task`.

The only allowed child is `/root/single_luna_executor`, configured as GPT-5.6 Luna / Max,
with the initial context fork set to `fork_turns = "none"`.

The parent model and reasoning effort remain user-controlled. They are not silently changed
by this package.

## Retained-target compatibility

Some runtimes may stop displaying an idle/retained child in `list_agents`. v1.1.0 treats that
visibility loss as observational, not authoritative.

Before any replacement or spawn decision:

1. call `list_agents`;
2. if the canonical child is hidden, send the same `/root/single_luna_executor` a
   `RECOVERY_PROBE` via `followup_task`;
3. on `STATUS: SINGLE_LUNA_REATTACHED`, reuse the same target even if it remains hidden;
4. on definitive target/thread/path not found, check whether the target existed earlier;
5. after prior existence, report `STATUS: SINGLE_LUNA_SESSION_STALE` and start a new session;
6. on an ambiguous timeout, transport failure, or missing completion, fail closed with no
   spawn and no replacement.

Initial spawn is valid only for a demonstrably fresh lifecycle: explicit invocation,
authorized implementation, no visible child, definitive recovery not-found, and no evidence
of an earlier child in the current session. If freshness is uncertain, do not guess.

## Runtime variability

If spawn-time model or reasoning-effort fields are not exposed, use the documented native
configuration defaults:

```toml
[agents]
enabled = true
max_concurrent_threads_per_session = 1
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "max"
```

If a future build uses a different feature flag or config namespace, follow that build's
documented surface while preserving the public lifecycle invariants. Do not increase the
concurrency limit to bypass retained-target behavior.

## Parent modes and reasoning boundary

Plan Mode keeps child count at zero until approval. Normal Mode skips formal Plan approval but
still requires parent-owned clarification and decisions. Luna performs bounded execution only;
an unresolved meaningful choice must return `STATUS: BLOCKED_REASONING` to the parent.

## Session-bound exit

`close_agent` is not assumed to exist. If unavailable, do not use `interrupt_agent` as a fake
close, do not create a replacement, and do not claim clean `DISABLED`. Report
`SESSION_COMPLETE` and start a new Codex session for a clean `DISABLED` state.

## Public boundary

The workflow is explicit-only, exactly-one-child, hookless, bridge-free, and free of external
state files. The installers do not read, write, or modify `hooks.json`; default installation
leaves `config.toml` unchanged.
