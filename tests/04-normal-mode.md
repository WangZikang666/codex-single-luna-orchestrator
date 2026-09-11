# Smoke Test 04 — Normal Mode

Use a NEW Codex session with Plan Mode OFF.

Invoke:

```text
$single-luna-orchestrator

Create normal_mode_test.txt with exactly:

mode=normal
executor=luna
reviewer=parent

Do not generate a formal Plan.
The parent should first confirm the request is execution-ready.
Then:
- call list_agents;
- initial child count must be 0;
- spawn exactly one /root/single_luna_executor;
- use fork_turns=none;
- only Luna creates the file;
- no additional children;
- parent performs final acceptance.
```

## PASS

- Formal Plan generated = NO.
- Initial live child count = 0.
- Initial `spawn_agent` calls = 1.
- Final live designated child count = 1 if the runtime keeps completed children live.
- Additional children = 0.
- Parent final acceptance = YES.
