# Contributing

Thanks for your interest in improving Codex Single-Luna Orchestrator.

This project intentionally has a narrow architecture:

> one parent thinker + exactly one reusable Luna execution child

Contributions should preserve that invariant unless a proposal explicitly targets a future
major version.

## Before opening a pull request

1. Fork the repository and create a focused branch.
2. Keep the skill explicit-only.
3. Do not add hooks, MCP bridges, external state daemons, or hidden auto-activation.
4. Do not add explorer/planner/tester/reviewer/fixer child roles.
5. Keep parent-owned reasoning and final acceptance.
6. Preserve `fork_turns = "none"` for the initial executor spawn.
7. Preserve same-child `followup_task` reuse.
8. Run:

```bash
python scripts/validate.py
```

9. If your change affects runtime behavior, run the relevant smoke test under `tests/`.

## Pull request checklist

Your PR should explain:

- the problem being solved;
- why the change is compatible with the one-child invariant;
- which files changed;
- validation performed;
- whether any Codex runtime/version assumption changed.

## Coding/style guidance

- Keep policy text concise and deterministic.
- Prefer fail-closed behavior over silent fallback.
- Do not hard-code personal paths, emails, tokens, project IDs, or local runtime paths.
- Installers must preserve user-owned `AGENTS.md` and `config.toml` content outside managed
  Single-Luna settings.
- Installers must not modify `hooks.json`.

## Runtime compatibility changes

If Codex changes the native multi-agent tool surface, open an issue first with:

- Codex/Desktop version;
- available tool names;
- observed `list_agents` output;
- exact failure;
- whether Plan Mode or Normal Mode was used.

## License

By contributing, you agree that your contributions are licensed under the repository's MIT
License.
