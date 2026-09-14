# Support

## Where to ask

Use:

- **GitHub Discussions** for setup questions, design discussion, and usage ideas;
- **GitHub Issues** for reproducible bugs and compatibility failures.

Repository:

https://github.com/WangZikang666/codex-single-luna-orchestrator

## Include this information

For runtime problems, please provide:

- operating system;
- Codex Desktop/CLI version;
- parent model and reasoning effort;
- Plan Mode or Normal Mode;
- whether Strict Single-Child config is enabled;
- output/summary from `list_agents`;
- exact error message;
- the relevant smoke test result.

Never post API keys, access tokens, private repository source, or personal credentials.

## Known design boundaries

- The skill is explicit-only.
- The only child is `/root/single_luna_executor`, and the workflow is session-bound after
  activation.
- `list_agents` visibility is observational, not authoritative. A hidden retained target is
  recovery-probed with `followup_task` before any spawn decision.
- `STATUS: SINGLE_LUNA_REATTACHED` means the same target is reusable; a definitive not-found
  after prior existence means `STATUS: SINGLE_LUNA_SESSION_STALE` and a new session.
- Ambiguous recovery errors fail closed with no spawn or replacement.
- `close_agent` may not exist in every Multi-Agent V2 runtime.
- If it is unavailable, report `SESSION_COMPLETE` and use a new session for clean `DISABLED`
  rather than fabricating a close or automatically creating a replacement.
