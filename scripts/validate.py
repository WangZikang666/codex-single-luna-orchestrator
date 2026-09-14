#!/usr/bin/env python3
"""Static validation for the public Single-Luna repository."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    "README.md",
    "README.zh-CN.md",
    ".gitattributes",
    "LICENSE",
    "CHANGELOG.md",
    ".gitignore",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "SUPPORT.md",
    "docs/ARCHITECTURE.md",
    "docs/COMPATIBILITY.md",
    "docs/TROUBLESHOOTING.md",
    "docs/RELEASE_NOTES_v1.1.0.md",
    "docs/RELEASE_NOTES_v1.0.0.md",
    "scripts/github-setup.ps1",
    ".github/CODEOWNERS",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/ISSUE_TEMPLATE/bug_report.yml",
    ".github/ISSUE_TEMPLATE/feature_request.yml",
    ".github/ISSUE_TEMPLATE/config.yml",
    "skills/single-luna-orchestrator/SKILL.md",
    "skills/single-luna-orchestrator/agents/openai.yaml",
    "integration/AGENTS.snippet.md",
    "integration/config.example.toml",
    "scripts/install.ps1",
    "scripts/uninstall.ps1",
    "scripts/install.sh",
    "scripts/validate.py",
    "tests/01-plan-mode.md",
    "tests/02-persistent-reuse.md",
    "tests/03-reasoning-boundary.md",
    "tests/04-normal-mode.md",
    "tests/05-session-bound-exit.md",
    "tests/06-retained-target-recovery.md",
    ".github/workflows/validate.yml",
]

TEXT_EXTENSIONS = {
    ".md", ".yaml", ".yml", ".toml", ".ps1", ".sh", ".py", ".txt", ""
}

def fail(msg: str) -> None:
    print(f"[FAIL] {msg}")
    raise SystemExit(1)

def ok(msg: str) -> None:
    print(f"[OK] {msg}")

for rel in REQUIRED:
    if not (ROOT / rel).exists():
        fail(f"missing required file: {rel}")
ok("required repository files exist")

skill_path = ROOT / "skills/single-luna-orchestrator/SKILL.md"
skill = skill_path.read_text(encoding="utf-8")

front = re.match(r"\A---\s*\n(.*?)\n---\s*\n", skill, re.S)
if not front:
    fail("SKILL.md YAML frontmatter missing")

frontmatter = front.group(1)
if not re.search(r"(?m)^name:\s*single-luna-orchestrator\s*$", frontmatter):
    fail("SKILL.md canonical name is incorrect")
if not re.search(r"(?m)^description:\s*\S", frontmatter):
    fail("SKILL.md description missing")
ok("SKILL.md frontmatter looks valid")

yaml_path = ROOT / "skills/single-luna-orchestrator/agents/openai.yaml"
yaml_text = yaml_path.read_text(encoding="utf-8")

required_yaml_fragments = [
    'display_name: "Single Luna Orchestrator"',
    "short_description:",
    "default_prompt:",
    "allow_implicit_invocation: false",
    "$single-luna-orchestrator",
]
for fragment in required_yaml_fragments:
    if fragment not in yaml_text:
        fail(f"openai.yaml missing: {fragment}")

m = re.search(r'short_description:\s*"([^"]+)"', yaml_text)
if not m:
    fail("openai.yaml short_description must be quoted")
if not (25 <= len(m.group(1)) <= 64):
    fail("openai.yaml short_description must be 25-64 characters")
ok("openai.yaml interface/policy checks passed")

agents = (ROOT / "integration/AGENTS.snippet.md").read_text(encoding="utf-8")
for marker in [
    "<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->",
    "<!-- END SINGLE-LUNA-ORCHESTRATOR -->",
]:
    if agents.count(marker) != 1:
        fail(f"AGENTS snippet marker count invalid: {marker}")

for required in [
    "$single-luna-orchestrator",
    "/root/single_luna_executor",
    "fork_turns = \"none\"",
    "followup_task",
    "BLOCKED_REASONING",
    "SESSION COMPLETE",
]:
    if required not in agents:
        fail(f"AGENTS snippet missing core rule: {required}")
ok("AGENTS managed block checks passed")

skill_requirements = [
    "/root/single_luna_executor",
    "fork_turns = \"none\"",
    "followup_task",
    "BLOCKED_REASONING",
    "SESSION COMPLETE",
    "Never create a second child",
]
for required in skill_requirements:
    if required not in skill:
        fail(f"SKILL.md missing core rule: {required}")
for required in [
    "explicitly invokes",
    "Do not silently activate",
    "GPT-5.6 Luna / Max",
    'model = "gpt-5.6-luna"',
    'reasoning_effort = "max"',
]:
    if required not in skill:
        fail(f"SKILL.md missing explicit-only/model rule: {required}")
ok("skill lifecycle checks passed")

CURRENT_VERSION = "1.1.0"

version_files = {
    "skills/single-luna-orchestrator/SKILL.md": r"# Single-Luna Orchestrator v1\.1\.0",
    "integration/AGENTS.snippet.md": r"Single-Luna Orchestrator v1\.1\.0",
    "README.md": r"Single-Luna Orchestrator v1\.1\.0",
    "README.zh-CN.md": r"Single-Luna Orchestrator v1\.1\.0",
    "CHANGELOG.md": r"## \[1\.1\.0\]",
    "docs/RELEASE_NOTES_v1.1.0.md": r"# Single-Luna Orchestrator v1\.1\.0",
    "scripts/install.ps1": r"single-luna-v1\.1\.0",
    "scripts/install.sh": r"single-luna-v1\.1\.0",
    "scripts/github-setup.ps1": r"release create v1\.1\.0",
}
for rel, pattern in version_files.items():
    text = (ROOT / rel).read_text(encoding="utf-8")
    if not re.search(pattern, text, re.I):
        fail(f"v{CURRENT_VERSION} marker missing from {rel}")

historical_notes = ROOT / "docs/RELEASE_NOTES_v1.0.0.md"
if "# Single-Luna Orchestrator v1.0.0" not in historical_notes.read_text(encoding="utf-8"):
    fail("historical v1.0.0 release notes were not retained")

current_files = [
    "skills/single-luna-orchestrator/SKILL.md",
    "integration/AGENTS.snippet.md",
    "docs/ARCHITECTURE.md",
    "docs/COMPATIBILITY.md",
    "docs/TROUBLESHOOTING.md",
    "docs/RELEASE_NOTES_v1.1.0.md",
    "scripts/install.ps1",
    "scripts/install.sh",
    "scripts/github-setup.ps1",
]
for rel in current_files:
    text = (ROOT / rel).read_text(encoding="utf-8")
    if "v1.0.0" in text:
        fail(f"stale v1.0.0 current-version claim in {rel}")
ok("v1.1.0 release markers and historical notes checks passed")

security = (ROOT / "SECURITY.md").read_text(encoding="utf-8")
if not re.search(r"(?m)^\|\s*1\.1\.x\s*\|\s*Yes\s*\|\s*$", security):
    fail("SECURITY.md must mark 1.1.x as supported")
if re.search(r"(?m)^\|\s*1\.0\.x\s*\|\s*Yes\s*\|\s*$", security):
    fail("SECURITY.md still marks unsupported 1.0.x as supported")
if not re.search(r"(?m)^\|\s*1\.0\.x\s*\|\s*No\s*\|\s*$", security):
    fail("SECURITY.md must mark 1.0.x as unsupported")
ok("security support-version checks passed")

recovery_requirements = [
    "ACTIVE_VISIBLE",
    "ACTIVE_HIDDEN",
    "ACTIVE_USABLE",
    "RECOVERY_PROBE",
    "STATUS: SINGLE_LUNA_REATTACHED",
    "STATUS: SINGLE_LUNA_SESSION_STALE",
    "list_agents` visibility is observational, not authoritative",
    "definitive",
    "ambiguous",
    "fail closed",
    "fresh lifecycle",
    "no replacement",
]
for required in recovery_requirements:
    if required not in skill:
        fail(f"SKILL.md missing retained-target recovery rule: {required}")

for required in [
    "ACTIVE_VISIBLE",
    "ACTIVE_HIDDEN",
    "ACTIVE_USABLE",
    "RECOVERY_PROBE",
    "STATUS: SINGLE_LUNA_REATTACHED",
    "STATUS: SINGLE_LUNA_SESSION_STALE",
    "freshness",
    "ambiguous recovery",
    "SESSION_COMPLETE",
]:
    if required not in agents:
        fail(f"AGENTS snippet missing recovery rule: {required}")

fresh_guard_fragments = [
    r"user explicitly\s+invoked",
    r"implementation is authorized",
    r"no child is visible",
    r"recovery probe\s+definitively found no canonical target",
    r"no evidence that a child was spawned\s+earlier",
]
for pattern in fresh_guard_fragments:
    if not re.search(pattern, skill, re.I):
        fail(f"SKILL.md missing fresh-lifecycle guard: {pattern}")

if "followup_task" not in skill[skill.find("## Activation and retained-target recovery"):skill.find("## Initial spawn requirements")]:
    fail("recovery procedure must use followup_task before initial spawn")
ok("retained-target recovery and fresh-lifecycle guard checks passed")

config = (ROOT / "integration/config.example.toml").read_text(encoding="utf-8")
for required in [
    "[features]",
    "multi_agent = true",
    "[agents]",
    "enabled = true",
    "max_concurrent_threads_per_session = 1",
    'default_subagent_model = "gpt-5.6-luna"',
    'default_subagent_reasoning_effort = "max"',
]:
    if required not in config:
        fail(f"config example missing: {required}")

allowed_config_keys = {
    "multi_agent",
    "enabled",
    "max_concurrent_threads_per_session",
    "default_subagent_model",
    "default_subagent_reasoning_effort",
}
for line in config.splitlines():
    stripped = line.split("#", 1)[0].strip()
    match = re.match(r"^([A-Za-z0-9_]+)\s*=", stripped)
    if match and match.group(1) not in allowed_config_keys:
        fail(f"unexpected config key in public example: {match.group(1)}")
for forbidden in ["[plugins", "[mcp_servers", "[projects", "notify =", "AppData"]:
    if forbidden in config:
        fail(f"private config fragment found in public example: {forbidden}")
ok("config example checks passed")

all_text = []
for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    if path.suffix.lower() in TEXT_EXTENSIONS or path.name in {"LICENSE", ".gitignore"}:
        try:
            all_text.append((path, path.read_text(encoding="utf-8")))
        except UnicodeDecodeError:
            pass

# Public-repo privacy guards.
for path, text in all_text:
    # Do not make the validator trip on its own guard regex literals.
    if path.resolve() == Path(__file__).resolve():
        continue
    checks = [
        (r"(?i)C:\\Users\\[^<\s\\]+", "absolute Windows user-home path"),
        (r"(?i)/Users/[^/<\s]+", "absolute macOS user-home path"),
        (r"(?i)/home/[^/<\s]+", "absolute Linux user-home path"),
        (r"(?i)\b[A-Z0-9._%+-]+@(gmail|outlook|qq|163|126)\.[A-Z]{2,}\b", "personal email"),
        (r"\[projects\.", "Codex project trust entry"),
        (r"mcp_servers\.single_luna_bridge", "legacy private MCP bridge config"),
        (r"(?im)^\s*notify\s*=", "private notification command"),
        (r"(?im)^\s*\[plugins\.", "private plugin configuration"),
        (r"(?i)\\AppData\\", "local runtime path"),
    ]
    for rx, label in checks:
        if re.search(rx, text):
            fail(f"{label} found in public file: {path.relative_to(ROOT)}")
ok("privacy/legacy guards passed")

# The public policy may mention forbidden replacement names as examples, but executable
# scripts must not manufacture alternate designated-child targets.
for path, text in all_text:
    if path.suffix not in {".ps1", ".sh", ".py"}:
        continue
    if re.search(r"single_luna_executor_(?:2|recovery|new)", text, re.I):
        fail(f"replacement child target found in executable file: {path.relative_to(ROOT)}")
ok("no-replacement executable guard passed")

# Ensure public code does not modify hooks.json.
for path, text in all_text:
    if path.resolve() == Path(__file__).resolve():
        continue
    if path.suffix not in {".ps1", ".sh", ".py"}:
        continue
    for line in text.splitlines():
        if "hooks.json" not in line:
            continue
        lowered = line.lower()
        allowed_notice = any(phrase in lowered for phrase in [
            "will not be read, written, or modified",
            "untouched",
            "intentionally",
        ])
        if not allowed_notice:
            fail(f"unexpected hooks.json handling in script: {path.relative_to(ROOT)}: {line.strip()}")
ok("hookless script guard passed")

print("\nStatic validation: PASS")
