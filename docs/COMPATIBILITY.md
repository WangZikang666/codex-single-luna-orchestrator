# Compatibility

## Validated design target

Public v1.0.0 is derived from a runtime-tested Native Minimal / Session-Bound design on a
Codex Desktop Multi-Agent V2 environment in September 2026.

The workflow expects native operations equivalent to:

- `list_agents`
- `spawn_agent`
- `followup_task`

The initial child should be:

- task name: `single_luna_executor`
- model: `gpt-5.6-luna`
- reasoning effort: `max`
- initial context fork: `fork_turns = "none"`

## Runtime variability

Codex multi-agent tool and configuration surfaces may evolve.

If spawn-time model/effort fields are not exposed, the strict configuration uses:

```toml
[agents]
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "max"
```

If a future build uses a different feature flag or config namespace, prefer the configuration
documented by that build while retaining the skill's lifecycle invariants.

## close_agent

`close_agent` is not assumed to exist.

If unavailable:

- do not use `interrupt_agent` as a fake close;
- report `SESSION COMPLETE`;
- do not create a replacement child;
- use a new Codex session for a clean DISABLED state.

## Parent modes

Plan Mode and Normal Mode are both supported.

Avoid parent modes that automatically/proactively create additional children when that
behavior cannot be reconciled with the strict one-child topology.
