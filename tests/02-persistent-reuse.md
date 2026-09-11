# Smoke Test 02 — Persistent Reuse

Continue the SAME session after Smoke Test 01. Do not invoke the skill again.

Send:

```text
Continue the same Single-Luna task.

Change hello.txt from counter=1 to counter=2.

Requirements:
- call list_agents first;
- /root/single_luna_executor must already exist;
- do NOT call spawn_agent;
- use followup_task with the existing designated child;
- keep it reusable;
- parent performs final acceptance.
```

## PASS

- `spawn_agent` calls this turn = 0.
- `followup_task` used = YES.
- Same `/root/single_luna_executor` reused.
- Additional children = 0.
- Final file is exactly:

```text
hello
counter=2
```
