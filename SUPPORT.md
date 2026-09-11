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
- The workflow is session-bound after ACTIVE begins.
- `close_agent` may not exist in every Multi-Agent V2 runtime.
- If the designated child disappears while ACTIVE, the policy fails closed instead of
  automatically creating a replacement.
