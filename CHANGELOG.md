# Changelog

All notable public changes to this project are documented here.

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
