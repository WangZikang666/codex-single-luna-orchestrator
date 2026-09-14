# Single-Luna Orchestrator v1.1.0

v1.1.0 fixes retained-target recovery in the public Native Minimal / Session-Bound design.
The earlier release notes remain available for the historical baseline.

## Highlights

- `list_agents` visibility is observational, not authoritative.
- A hidden `/root/single_luna_executor` is recovery-probed through `followup_task` before
  any spawn decision.
- A successful probe returns `STATUS: SINGLE_LUNA_REATTACHED` and reuses the same target,
  even if it remains hidden.
- A definitive not-found result after prior child existence returns
  `STATUS: SINGLE_LUNA_SESSION_STALE` and requires a new Codex session.
- Ambiguous recovery failures fail closed: no spawn, no replacement, and no alternate task
  name.
- Initial spawn is allowed only for a demonstrably fresh lifecycle, with
  `fork_turns = "none"` and GPT-5.6 Luna / Max settings.
- Session-bound completion reports `SESSION_COMPLETE` when `close_agent` is unavailable;
  clean `DISABLED` requires a new session.
- The workflow remains explicit-only, exactly-one-child, hookless, bridge-free, and without
  external state.

## Documentation and validation

- The full normative policy is in [`skills/single-luna-orchestrator/SKILL.md`](../skills/single-luna-orchestrator/SKILL.md).
- The installer-managed enforcement summary is in
  [`integration/AGENTS.snippet.md`](../integration/AGENTS.snippet.md).
- Six smoke-test specifications cover Plan Mode, reuse, reasoning boundaries, Normal Mode,
  session-bound exit, and retained-target recovery.
- `scripts/validate.py` checks release artifacts, recovery outcomes, freshness guards,
  explicit-only activation, privacy, Luna / Max, and the no-replacement invariant.

## Upgrade note

Install v1.1.0 into a new Codex session. Existing user content outside the marked AGENTS
block and the documented Strict-mode keys is preserved. The default installer still leaves
`config.toml` unchanged and never reads, writes, or modifies `hooks.json`.
