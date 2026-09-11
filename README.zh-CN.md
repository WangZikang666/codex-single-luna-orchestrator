# Codex Single-Luna Orchestrator

[![Validate](https://github.com/WangZikang666/codex-single-luna-orchestrator/actions/workflows/validate.yml/badge.svg)](https://github.com/WangZikang666/codex-single-luna-orchestrator/actions/workflows/validate.yml)
[![Release](https://img.shields.io/github/v/release/WangZikang666/codex-single-luna-orchestrator?display_name=tag)](https://github.com/WangZikang666/codex-single-luna-orchestrator/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Codex Skill](https://img.shields.io/badge/Codex-Skill-111827)](skills/single-luna-orchestrator/SKILL.md)
[![Hookless](https://img.shields.io/badge/architecture-hookless-0f766e)](docs/ARCHITECTURE.md)

> **语言：** [English](README.md) | 简体中文

**Single-Luna Orchestrator v1.0.0** 是一个显式调用的 Codex orchestration skill。

它的目标非常明确：

> **让当前父代模型负责需求理解、规划、困难推理、决策和最终验收；让唯一一个可持续复用的 GPT-5.6 Luna / Max 原生 child 负责具体执行。**

它特别适合长时间编码任务：你希望强模型把 token 花在真正需要判断的地方，而不是反复执行机械操作；同时又不希望 Codex 不断创建 explorer、reviewer、tester、fixer 等越来越多的子 agent。

> 本项目是独立社区项目，与 OpenAI 无隶属或官方背书关系。

## 为什么做 Single-Luna？

长任务通常同时需要两种能力：

- **强父代**：理解需求、做架构、推理、定位复杂问题、权衡方案、最终验收；
- **执行 worker**：改文件、跑命令、测试、lint/format、机械性实现、收集证据。

Single-Luna 不采用不断扩大的 agent tree，而固定为：

```text
一个 Parent Thinker
        +
一个 Persistent Luna Executor
```

整体结构：

```text
用户选择的 Parent
        |
        | 需求 / Plan / 推理 / 决策
        v
紧凑、已决策的执行指令
        |
        v
/root/single_luna_executor
GPT-5.6 Luna / Max
        |
        | 编辑 / 命令 / 测试 / 证据
        v
同一个 Parent 最终验收
```

Luna **只创建一次**，之后一直通过 `followup_task` 复用同一个 child。

## 核心原则

- 只能显式调用：`$single-luna-orchestrator`
- 支持 **Plan Mode**
- 支持 **Normal Mode**
- Plan 批准前：**Luna 数量必须为 0**
- 真正执行时：只允许一个 `/root/single_luna_executor`
- 初始 spawn 必须使用 `fork_turns = "none"`
- 后续实现全部通过 `followup_task` 复用同一个 child
- 不创建 explorer / planner / tester / verifier / auditor / reviewer / fixer / nested child
- 所有有意义的推理由 Parent 负责
- Luna 遇到需要判断的问题必须返回 `STATUS: BLOCKED_REASONING`
- 最终 PASS / FAIL 由当前 Parent 自己判断
- **Hookless**
- **无 MCP bridge**
- **无 app-server sidecar**
- **无外部持久化状态**
- ACTIVE 后采用 **Session-Bound** 生命周期

## 已验证行为

| 能力 | v1.0.0 |
| --- | --- |
| 显式调用 | ✅ |
| Plan 批准前 child = 0 | ✅ |
| Normal Mode | ✅ |
| 原生 child 首次只 spawn 一次 | ✅ |
| `followup_task` 持续复用同一 child | ✅ |
| `fork_turns = "none"` | ✅ |
| `BLOCKED_REASONING` 回交父代 | ✅ |
| Parent 最终验收 | ✅ |
| 防止额外 child fan-out | ✅（规则约束） |
| hooks / MCP bridge | 不使用 |
| Session-Bound completion | ✅ |

详细验证见 [`tests/`](tests/) 与 [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md)。

## 环境要求

本 Skill 期望当前 Codex runtime 暴露原生 multi-agent 能力：

- `list_agents`
- `spawn_agent`
- `followup_task`

并能够让唯一 child 使用：

```text
model = gpt-5.6-luna
reasoning effort = max
```

模型与 reasoning effort 可以来自：

- 当前 `spawn_agent` schema 的显式参数；或
- `[agents]` 默认配置。

该设计在 **2026 年 9 月 Codex Desktop Multi-Agent V2** 环境中完成过真实 runtime smoke test。

Codex 的 multi-agent 工具和配置可能继续变化；当 runtime 与预期不一致时，本项目倾向于 **fail closed**，而不是静默改变拓扑。

## 安装

### Windows

```powershell
git clone https://github.com/WangZikang666/codex-single-luna-orchestrator.git
cd codex-single-luna-orchestrator

powershell.exe `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File ".\scripts\install.ps1"
```

默认安装只做：

1. 安装 `skills/single-luna-orchestrator`
2. 把受管理的 Single-Luna 区块 merge 到 `~/.codex/AGENTS.md`
3. 修改前自动备份
4. **不修改 `config.toml`**
5. **不读取、不写入、不修改 `hooks.json`**

如果你希望开启严格的单 child 全局 guard：

```powershell
powershell.exe `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File ".\scripts\install.ps1" `
  -StrictSingleChild
```

### macOS / Linux

```bash
git clone https://github.com/WangZikang666/codex-single-luna-orchestrator.git
cd codex-single-luna-orchestrator

bash scripts/install.sh
```

Strict 模式：

```bash
bash scripts/install.sh --strict-single-child
```

安装后请**完全重启 Codex**，并用一个新 session 测试。

## Strict 模式会修改什么？

Strict 模式会 merge：

```toml
[features]
multi_agent = true

[agents]
enabled = true
max_concurrent_threads_per_session = 1
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "max"
```

参考：

[`integration/config.example.toml`](integration/config.example.toml)

注意：

> `max_concurrent_threads_per_session = 1` 是一个全局的 session 级 spawned-thread guard。

因此它非常适合 Single-Luna，但可能与其他需要多 child 的 workflow 冲突。

所以：

- 默认安装 **不改 `config.toml`**
- 只有你显式启用 Strict 模式时才 merge 这些字段

## AGENTS.md 如何安装？

安装器不会覆盖整个 `AGENTS.md`。

只管理这一段：

```text
<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->
...
<!-- END SINGLE-LUNA-ORCHESTRATOR -->
```

区块以外的用户规则全部保留。

源文件：

[`integration/AGENTS.snippet.md`](integration/AGENTS.snippet.md)

## Plan Mode 使用方法

新建 Codex session，选择你想用的父代模型与 reasoning effort，打开 Plan Mode：

```text
$single-luna-orchestrator

请先规划这个任务。在我批准 Plan 之前不要执行。
```

生命周期：

```text
DISABLED
   |
   | 显式调用
   v
ARMED
   |
   | Plan 阶段
   | Parent only
   | Luna = 0
   |
   | 用户批准 Plan
   v
ACTIVE
   |
   | spawn /root/single_luna_executor 一次
   |
   | followup_task -> 同一个 Luna
   | followup_task -> 同一个 Luna
   | followup_task -> 同一个 Luna
   v
SESSION COMPLETE
   |
   | 结束当前 Codex session
   v
新 session = clean DISABLED
```

## Normal Mode 使用方法

关闭 Plan Mode：

```text
$single-luna-orchestrator

实现这个任务。所有歧义先由父代解决，再把明确的执行任务交给 Luna。
```

Normal Mode 不生成正式 Plan，但职责边界完全不变：

```text
Parent
= 理解
= 决策
= 推理
= 最终验收

Luna
= 执行
```

## Reasoning Boundary

Luna 可以执行具体工作，但不能拥有高层判断权。

当出现尚未解决的关键选择时，Luna 必须停止：

```text
STATUS: BLOCKED_REASONING
EVIDENCE: <只有事实>
QUESTION_FOR_ROOT: <需要 Parent 决定的具体问题>
SAFE_EXECUTION_COMPLETED: <已经安全完成的工作>
```

然后：

```text
Luna BLOCKED
     ↓
Parent 推理 / 决策
     ↓
followup_task
     ↓
同一个 Luna 执行父代已经决定好的方案
```

## Compact Execution Packet

Parent 推荐给 Luna 发送：

```text
OBJECTIVE:
SCOPE:
ROOT_DECISION:
CONSTRAINTS:
EXPECTED_RESULT:
VERIFY:
STOP_IF:
```

不要：

- 把未解决的 A/B 方案直接丢给 Luna
- 让 Luna “自己选最佳架构”
- 把完整 Plan 对话全部复制给 Luna

## 为什么使用 fork_turns = none？

因为 Luna 不需要 Parent 的整个 Plan 历史。

初次 spawn 使用：

```text
fork_turns = "none"
```

Parent 只发送已经压缩、已经决策完成的执行信息。

这样可以减少：

- child 上下文浪费
- 长 Plan 历史重复
- 不必要的 reasoning token
- Parent 与 Executor 职责混淆

## Spawn Once

一旦存在：

```text
/root/single_luna_executor
```

后续当前 activated task 中：

```text
禁止再次 spawn_agent
```

每轮实现：

```text
list_agents
   ↓
确认 /root/single_luna_executor
   ↓
followup_task
   ↓
同一个 Luna
```

如果 ACTIVE 状态下 designated child 消失：

```text
FAIL CLOSED
```

不自动创建 replacement。

## Parent Final Acceptance

不创建 reviewer child。

Luna 完成后由**当前同一个 Parent**：

- 查看真实文件 / diff
- 查看真实测试与命令结果
- 与 Plan 比较
- 与用户要求比较
- 推理潜在 regression / edge case
- 决定 PASS / FAIL

如果 FAIL：

```text
Parent 决定具体修正
     ↓
followup_task
     ↓
同一个 Luna 修正
     ↓
Parent 再次验收
```

## Session-Bound Exit

不要假设当前 Multi-Agent V2 一定有 `close_agent`。

任务完成时：

1. `list_agents`
2. 如果 `close_agent` 存在，可以关闭 designated child
3. 如果不存在：
   - 不伪造关闭成功
   - 不把 `interrupt_agent` 当作 close
   - 不创建 replacement
   - 不声称当前 session 已 clean DISABLED
4. 报告：

```text
SESSION COMPLETE
```

5. 新建 Codex session 获得 clean `DISABLED`

## Skill 显式调用

规范 token：

```text
$single-luna-orchestrator
```

如果 Codex UI 某个版本的 Skill picker 插入了不同大小写，请手动输入上述全小写 token。

## Smoke Tests

仓库包含 5 个真实工作流 smoke tests：

1. [`01-plan-mode.md`](tests/01-plan-mode.md)
2. [`02-persistent-reuse.md`](tests/02-persistent-reuse.md)
3. [`03-reasoning-boundary.md`](tests/03-reasoning-boundary.md)
4. [`04-normal-mode.md`](tests/04-normal-mode.md)
5. [`05-session-bound-exit.md`](tests/05-session-bound-exit.md)

静态验证：

```bash
python scripts/validate.py
```

## 卸载

Windows：

```powershell
powershell.exe `
  -NoProfile `
  -ExecutionPolicy Bypass `
  -File ".\scripts\uninstall.ps1"
```

macOS / Linux：

```bash
bash scripts/install.sh --uninstall
```

卸载时：

- 删除 managed Skill
- 删除 managed AGENTS block
- 不静默修改 `config.toml`
- 不修改 `hooks.json`

如果之前启用了 Strict 模式，需要恢复 config，可以使用安装时生成的 timestamped backup。

## 文档

- [Architecture](docs/ARCHITECTURE.md)
- [Compatibility](docs/COMPATIBILITY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)
- [Support](SUPPORT.md)

## 社区

- 使用问题与讨论：[GitHub Discussions](https://github.com/WangZikang666/codex-single-luna-orchestrator/discussions)
- Bug：[GitHub Issues](https://github.com/WangZikang666/codex-single-luna-orchestrator/issues)
- 贡献指南：[`CONTRIBUTING.md`](CONTRIBUTING.md)
- 安全策略：[`SECURITY.md`](SECURITY.md)

## 项目结构

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
├── skills/
├── integration/
├── docs/
├── scripts/
├── tests/
└── .github/
```

## License

MIT License，见 [`LICENSE`](LICENSE)。
