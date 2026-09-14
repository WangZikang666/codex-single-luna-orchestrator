# Smoke Test 02 — Persistent Reuse

Release behavior: v1.1.0.

Continue the SAME session after Smoke Test 01. Do not invoke the skill again.

Send:

```text
Continue the same Single-Luna task.

Change hello.txt from counter=1 to counter=2.

Requirements:
- call list_agents first;
- /root/single_luna_executor must already exist logically, whether visible or retained;
- if hidden from `list_agents`, send the canonical `RECOVERY_PROBE` with `followup_task` and
  require `STATUS: SINGLE_LUNA_REATTACHED`;
- do NOT call spawn_agent or create a replacement;
- use followup_task with the same designated child;
- keep it reusable;
- parent performs final acceptance.
```

## PASS

- `spawn_agent` calls this turn = 0.
- `followup_task` used = YES.
- Same `/root/single_luna_executor` reused.
- Hidden-target recovery, when needed, used the same canonical target.
- Additional children = 0.
- Final file is exactly:

```text
hello
counter=2
```
