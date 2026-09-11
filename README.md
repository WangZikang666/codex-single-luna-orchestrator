# Codex Single-Luna Orchestrator

[![Validate](https://github.com/WangZikang666/codex-single-luna-orchestrator/actions/workflows/validate.yml/badge.svg)](https://github.com/WangZikang666/codex-single-luna-orchestrator/actions/workflows/validate.yml)
[![Release](https://img.shields.io/github/v/release/WangZikang666/codex-single-luna-orchestrator?display_name=tag)](https://github.com/WangZikang666/codex-single-luna-orchestrator/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Codex Skill](https://img.shields.io/badge/Codex-Skill-111827)](skills/single-luna-orchestrator/SKILL.md)
[![Hookless](https://img.shields.io/badge/architecture-hookless-0f766e)](docs/ARCHITECTURE.md)

> **Language:** English | [简体中文](README.zh-CN.md)

**Single-Luna Orchestrator v1.0.0** is an explicit-only Codex skill that keeps planning,
difficult reasoning, decisions, and final acceptance in the current parent model while
delegating implementation to exactly **one reusable GPT-5.6 Luna / Max native child**.

It is designed for long coding sessions where you want a strong parent to **think and review**
while a cheaper/faster child **executes**, without spawning explorer/reviewer/tester/fixer
agent trees.

> Independent community project. Not affiliated with or endorsed by OpenAI.


## Why Single-Luna?

Long Codex tasks often benefit from two different capabilities:

- a strong parent for requirements, architecture, hard debugging, tradeoffs, and acceptance;
- a fast execution worker for edits, commands, tests, formatting, and mechanical changes.

Single-Luna deliberately avoids a growing tree of planner/explorer/reviewer/fixer agents.
Instead, it keeps one reusable execution child alive and routes every meaningful decision
back to the parent.

This makes the topology easy to reason about:

```text
one parent thinker + one persistent executor
```

## Tested behavior

| Capability | v1.0.0 |
| --- | --- |
| Explicit-only activation | ✅ |
| Plan Mode: zero child before approval | ✅ |
| Normal Mode | ✅ |
| Initial native spawn exactly once | ✅ |
| Same-child `followup_task` reuse | ✅ |
| `fork_turns = "none"` | ✅ |
| `BLOCKED_REASONING` handoff | ✅ |
| Parent final acceptance | ✅ |
| Additional child fan-out | prevented by policy |
| Hooks / MCP bridge | not used |
| Session-bound completion | ✅ |

See [`tests/`](tests/) and [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

## Core topology

```text
user-selected parent
        |
        | plan / clarify / reason / decide
        v
compact execution packet
        |
        v
/root/single_luna_executor
GPT-5.6 Luna / Max
        |
        | edit / run / test / collect evidence
        v
same parent reviews and decides PASS/FAIL
```

The child is created once and then reused with `followup_task`.

## Design principles

- Explicit-only activation: type `$single-luna-orchestrator`.
- Plan Mode compatible: before Plan approval, Luna count stays **0**.
- Normal Mode compatible: the parent resolves requirements first, then execution begins.
- Exactly one native execution child: `/root/single_luna_executor`.
- Initial child spawn uses `fork_turns = "none"` to avoid copying the full planning history.
- Later implementation uses `followup_task` to the same child.
- No explorer, planner, tester, verifier, auditor, reviewer, fixer, or nested child.
- Parent owns all meaningful reasoning and final acceptance.
- Luna is execution-only and returns `STATUS: BLOCKED_REASONING` when a decision is required.
- Hookless: no SessionStart/UserPromptSubmit/SubagentStart hooks.
- No MCP bridge or app-server sidecar.
- Session-bound after ACTIVE begins.

## Requirements

This workflow expects a Codex runtime that exposes the native multi-agent operations used by
the skill:

- `list_agents`
- `spawn_agent`
- `followup_task`

It also expects access to `gpt-5.6-luna` at reasoning effort `max`, either through spawn
arguments or through `[agents]` defaults.

The project was validated against a Codex Desktop Multi-Agent V2 environment in September
2026. Codex multi-agent configuration and tool surfaces can evolve; if your runtime proves
that a required capability is unavailable, the skill is designed to fail closed instead of
silently changing topology.

## Install

### Windows

Clone the repository and run:

```powershell
git clone https://github.com/WangZikang666/codex-single-luna-orchestrator.git
cd codex-single-luna-orchestrator

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Default installation:

1. installs `skills/single-luna-orchestrator` into your Codex skill directory;
2. merges the managed Single-Luna block into `~/.codex/AGENTS.md`;
3. backs up files before changing them;
4. does **not** modify `config.toml`;
5. does **not** read, write, or modify `hooks.json`.

For the strict single-child guard:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\install.ps1 `
  -StrictSingleChild
```

Strict mode additionally merges the recommended native-agent settings into
`~/.codex/config.toml` without replacing the rest of the file.

### macOS / Linux

```bash
git clone https://github.com/WangZikang666/codex-single-luna-orchestrator.git
cd codex-single-luna-orchestrator

bash scripts/install.sh
```

Strict mode:

```bash
bash scripts/install.sh --strict-single-child
```

After installation, fully restart Codex before testing.

## What Strict mode changes

Strict mode merges the equivalent of:

```toml
[features]
multi_agent = true

[agents]
enabled = true
max_concurrent_threads_per_session = 1
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "max"
```

See [`integration/config.example.toml`](integration/config.example.toml).

`max_concurrent_threads_per_session = 1` is a **global per-session spawned-thread guard**.
That is useful for Single-Luna, but it can conflict with unrelated multi-child workflows.
For that reason, the default installer does not change `config.toml`.

If your Codex build exposes a newer V2-specific feature flag, follow the configuration surface
for that build. The skill itself still enforces the one-child lifecycle by checking
`list_agents` before every implementation-capable delegation.

## What the installer does to AGENTS.md

The installer does not replace your entire `AGENTS.md`. It manages only this delimited block:

```text
<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->
...
<!-- END SINGLE-LUNA-ORCHESTRATOR -->
```

Existing rules outside that block are preserved.

The source block is in
[`integration/AGENTS.snippet.md`](integration/AGENTS.snippet.md).

## Usage

### Plan Mode

Start a new Codex session, select your preferred parent model/reasoning effort, enable Plan
Mode, then explicitly invoke:

```text
$single-luna-orchestrator

Plan this task. Do not execute until I approve the Plan.
```

Expected lifecycle:

```text
DISABLED
   |
   | explicit invocation
   v
ARMED
   |
   | Plan discussion: parent only, Luna count = 0
   |
   | Plan approved
   v
ACTIVE
   |
   | spawn /root/single_luna_executor exactly once
   |
   | followup_task -> same child
   | followup_task -> same child
   | ...
   v
SESSION COMPLETE
   |
   | leave/end current Codex session
   v
new session = clean DISABLED
```

### Normal Mode

With Plan Mode off:

```text
$single-luna-orchestrator

Implement this task. Resolve any ambiguity in the parent before delegating execution.
```

There is no formal Plan approval step, but the parent still owns requirements, design,
reasoning, and final review.

## Reasoning boundary

The Luna child may execute concrete work, but it must not own high-level judgment.

When a meaningful unresolved decision is encountered, the child must stop and return:

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <concrete facts only>
QUESTION_FOR_ROOT: <exact decision needed>
SAFE_EXECUTION_COMPLETED: <safe work already completed>
```

The parent then makes the decision and sends a decision-complete instruction back to the
**same** child using `followup_task`.

## Compact execution packet

The parent should send bounded, decision-complete instructions:

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

Do not send unresolved alternatives or the entire Plan transcript.

## Session-bound exit

Do not assume the current Multi-Agent V2 runtime exposes `close_agent`.

When the task is complete:

- call `list_agents`;
- if `close_agent` exists, it may close the designated child;
- if it does not exist, do not fake a close;
- do not use `interrupt_agent` as a close substitute;
- do not spawn a replacement;
- report `SESSION COMPLETE`;
- start a new Codex session for a clean `DISABLED` state.

## Explicit invocation note

The canonical invocation is lowercase:

```text
$single-luna-orchestrator
```

If a Codex UI skill picker ever inserts a differently-cased display name and explicit
invocation fails, type the canonical lowercase token manually.

## Tests

Manual runtime smoke tests live under [`tests/`](tests/):

1. `01-plan-mode.md`
2. `02-persistent-reuse.md`
3. `03-reasoning-boundary.md`
4. `04-normal-mode.md`
5. `05-session-bound-exit.md`

Static repository validation:

```bash
python scripts/validate.py
```

## Uninstall

Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall.ps1
```

macOS / Linux:

```bash
bash scripts/install.sh --uninstall
```

Uninstall removes the managed skill folder and the managed `AGENTS.md` block. It does not
silently rewrite your `config.toml`; if you used Strict mode and want to restore previous
configuration, use the timestamped backup created during installation or edit the four
Single-Luna keys manually.

## Repository layout

```text
.
├── README.md
├── README.zh-CN.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── SUPPORT.md
├── .gitignore
├── .gitattributes
├── skills/
│   └── single-luna-orchestrator/
│       ├── SKILL.md
│       └── agents/
│           └── openai.yaml
├── integration/
│   ├── AGENTS.snippet.md
│   └── config.example.toml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── COMPATIBILITY.md
│   ├── TROUBLESHOOTING.md
│   └── RELEASE_NOTES_v1.0.0.md
├── scripts/
│   ├── install.ps1
│   ├── uninstall.ps1
│   ├── install.sh
│   ├── github-setup.ps1
│   └── validate.py
├── tests/
│   ├── 01-plan-mode.md
│   ├── 02-persistent-reuse.md
│   ├── 03-reasoning-boundary.md
│   ├── 04-normal-mode.md
│   └── 05-session-bound-exit.md
└── .github/
    ├── CODEOWNERS
    ├── PULL_REQUEST_TEMPLATE.md
    ├── ISSUE_TEMPLATE/
    │   ├── bug_report.yml
    │   ├── feature_request.yml
    │   └── config.yml
    └── workflows/
        └── validate.yml
```

## 中文快速说明

这是一个 **Codex 原生、显式调用、单 Luna 持久执行** 的 orchestration skill。

核心规则：

- `$single-luna-orchestrator` 才会启用；
- Plan 阶段不创建 Luna；
- 真正执行时只创建一个 `/root/single_luna_executor`；
- 后续全部 `followup_task` 复用同一个 Luna；
- 父代负责需求、架构、推理、决策和最终验收；
- Luna 只负责执行，遇到需要判断的问题返回 `BLOCKED_REASONING`；
- 不使用 hooks，不使用 MCP bridge；
- ACTIVE 后按 session-bound 规则工作。

Windows 默认安装不会改 `config.toml`；只有显式使用 `-StrictSingleChild` 才会合并
单 child 配置。


## Community

- Questions and ideas: [GitHub Discussions](https://github.com/WangZikang666/codex-single-luna-orchestrator/discussions)
- Bugs: [Issue tracker](https://github.com/WangZikang666/codex-single-luna-orchestrator/issues)
- Contributing: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Security: [`SECURITY.md`](SECURITY.md)
- Support: [`SUPPORT.md`](SUPPORT.md)

## License

MIT. See [`LICENSE`](LICENSE).
