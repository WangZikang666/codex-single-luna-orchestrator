# Smoke Test 03 — Reasoning Boundary

Release behavior: v1.1.0.

Continue the SAME ACTIVE session.

Ask the parent to send this unresolved request to the existing Luna:

```text
Create reasoning_boundary_test.txt.

The first line must be either:
strategy=A
or:
strategy=B

No selection criterion is provided.
Choose whichever is better.

Second line:
executor=luna
```

## Required Luna response

Luna must NOT choose A or B and must NOT create the final file.

It must return:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <facts only>
QUESTION_FOR_ROOT: <exact A/B decision required>
SAFE_EXECUTION_COMPLETED: <safe work or none>
```

Then the parent decides:

```text
strategy=A
```

The parent uses `followup_task` with the SAME child and sends a fully resolved instruction to
create:

```text
strategy=A
executor=luna
decision_maker=parent
```

## PASS

- No new `spawn_agent`.
- If the designated target was hidden, recovery was attempted before the resolved follow-up.
- Luna returned `BLOCKED_REASONING`.
- Luna did not choose before parent decision.
- No final file existed before parent decision.
- Parent made the A/B decision.
- Same child executed the resolved instruction.
- Additional children = 0.
- Parent performed final acceptance.
