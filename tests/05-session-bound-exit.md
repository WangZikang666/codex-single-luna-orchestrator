# Smoke Test 05 — Session-Bound Exit

Run at the end of an ACTIVE Single-Luna task:

```text
This Single-Luna task is complete.

Apply the session-bound exit rules:
1. call list_agents;
2. report whether /root/single_luna_executor is present;
3. check whether close_agent is available;
4. if close_agent is available, it may close the designated child;
5. if close_agent is unavailable:
   - do not treat interrupt_agent as close;
   - do not claim the child was closed;
   - do not claim the same session is cleanly DISABLED;
   - do not spawn a replacement;
   - report SESSION COMPLETE;
6. stop assigning new implementation work;
7. report that a new Codex session is the clean DISABLED state.
```

## PASS when `close_agent` is unavailable

All of the following are acceptable/required:

- designated child may be present OR already absent;
- `close_agent actually used = NOT_AVAILABLE`;
- `interrupt_agent misused as close = NO`;
- replacement child created = NO;
- current session state = `SESSION_COMPLETE`;
- clean DISABLED requires new session = YES.

The child being already absent does not fail this test. The key requirement is that the parent
does not fabricate a close operation or create a replacement.
