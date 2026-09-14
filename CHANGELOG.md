# Changelog

All notable public changes to this project are documented here.

## [1.1.0] - 2026-09-14

Retained-target recovery for the public Native Minimal / Session-Bound design.

### Added

- `ACTIVE_VISIBLE`, `ACTIVE_HIDDEN`, and `ACTIVE_USABLE` lifecycle states.
- Canonical `RECOVERY_PROBE` through `followup_task` when `list_agents` does not show the
  designated child.
- Exact `STATUS: SINGLE_LUNA_REATTACHED` recovery success outcome.
- Fresh-lifecycle guard before the only initial spawn.
- `STATUS: SINGLE_LUNA_SESSION_STALE` when a previously existing canonical target is
  definitively unreachable.
- Explicit fail-closed handling for ambiguous recovery failures; no replacement child is
  created.
- Smoke Test 06 for retained-target recovery and a new-session requirement after stale state.

### Changed

- `list_agents` visibility is documented as observational, not authoritative.
- Re-invocation and long-idle behavior now probes and reuses the same canonical target.
- Installer backups, output, and the GitHub release helper target v1.1.0.
- Session-bound exit reports `SESSION_COMPLETE` honestly when `close_agent` is unavailable;
  a new session is required for clean `DISABLED`.

## [1.0.0] - 2026-09-11

Initial public release.

### Added

- Explicit-only `$single-luna-orchestrator` Codex skill.
- Plan Mode workflow with zero child before approval.
- Normal Mode workflow.
- Exactly-one native child topology using `/root/single_luna_executor`.
- `fork_turns = "none"` initial spawn policy.
- Persistent child reuse through `followup_task`.
- Parent-owned planning, difficult reasoning, decisions, corrections, and final acceptance.
- `STATUS: BLOCKED_REASONING` handoff contract for unresolved decisions.
- Fail-closed behavior if the designated child disappears.
- Session-bound completion semantics for runtimes without `close_agent`.
- Hookless design with no MCP bridge or external state service.
- Safe AGENTS block merge installers for Windows, macOS, and Linux.
- Optional strict single-child config merge.
- Five runtime smoke tests.
- Static repository validation and GitHub Actions workflow.
- GitHub community health files and issue/PR templates.
- Repository setup helper for About metadata, topics, merge policy, labels, and release.

### Validation history

The internal Native Minimal / Session-Bound design was runtime-tested before this public
release for:

- Plan-stage zero-child behavior;
- initial single native spawn;
- same-child `followup_task` reuse;
- reasoning-boundary handoff;
- parent final acceptance;
- Normal Mode;
- session-bound exit behavior.
