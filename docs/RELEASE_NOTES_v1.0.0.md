# Single-Luna Orchestrator v1.0.0

Initial public release of the Native Minimal / Session-Bound design.

## Highlights

- Explicit-only `$single-luna-orchestrator`.
- Plan Mode with zero child before approval.
- Normal Mode support.
- Exactly one native GPT-5.6 Luna / Max executor.
- Initial `fork_turns = "none"`.
- Same-child reuse through `followup_task`.
- Parent-owned planning, difficult reasoning, decisions, corrections, and final acceptance.
- `STATUS: BLOCKED_REASONING` handoff for unresolved choices.
- No explorer/reviewer/tester/fixer child fan-out.
- Hookless and bridge-free.
- Session-bound completion when `close_agent` is unavailable.
- Safe Windows/macOS/Linux installers.
- Optional strict single-child configuration.
- Five runtime smoke tests and GitHub Actions static validation.

See the README for installation and compatibility details.
