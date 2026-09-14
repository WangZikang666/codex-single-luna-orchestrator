#!/usr/bin/env bash
set -euo pipefail

STRICT=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --strict-single-child) STRICT=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--strict-single-child] [--uninstall]" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

SKILL_SOURCE="$REPO_ROOT/skills/single-luna-orchestrator"
SNIPPET_SOURCE="$REPO_ROOT/integration/AGENTS.snippet.md"
SKILL_TARGET="$CODEX_HOME/skills/single-luna-orchestrator"
AGENTS_TARGET="$CODEX_HOME/AGENTS.md"
CONFIG_TARGET="$CODEX_HOME/config.toml"

BEGIN_MARKER='<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->'
END_MARKER='<!-- END SINGLE-LUNA-ORCHESTRATOR -->'
STAMP="$(date +%Y%m%d-%H%M%S)"

remove_agents_block() {
  local target="$1"
  [[ -f "$target" ]] || return 0

  python3 - "$target" "$BEGIN_MARKER" "$END_MARKER" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
begin = sys.argv[2]
end = sys.argv[3]
text = path.read_text(encoding="utf-8")
pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)
updated = pattern.sub("", text).strip()

if updated:
    path.write_text(updated + "\n", encoding="utf-8")
else:
    path.unlink()
PY
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  echo "=== Single-Luna Orchestrator uninstaller ==="
  echo "hooks.json will not be read, written, or modified."

  rm -rf "$SKILL_TARGET"
  remove_agents_block "$AGENTS_TARGET"

  echo "[OK] Skill and managed AGENTS block removed."
  echo "config.toml intentionally left unchanged."
  echo "If Strict mode was used, restore a timestamped backup or edit the Single-Luna keys manually."
  echo "hooks.json untouched."
  exit 0
fi

echo "=== Single-Luna Orchestrator v1.1.0 installer ==="
echo "Codex home: $CODEX_HOME"
echo "Strict single-child config: $STRICT"
echo "hooks.json will not be read, written, or modified."
echo

mkdir -p "$CODEX_HOME/skills"

if [[ -f "$AGENTS_TARGET" ]]; then
  cp "$AGENTS_TARGET" "$AGENTS_TARGET.before-single-luna-v1.1.0-$STAMP.bak"
fi

if [[ -d "$SKILL_TARGET" ]]; then
  cp -R "$SKILL_TARGET" "$SKILL_TARGET.before-single-luna-v1.1.0-$STAMP"
  rm -rf "$SKILL_TARGET"
fi

cp -R "$SKILL_SOURCE" "$SKILL_TARGET"
echo "[OK] Skill installed: $SKILL_TARGET"

python3 - "$AGENTS_TARGET" "$SNIPPET_SOURCE" "$BEGIN_MARKER" "$END_MARKER" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
snippet_path = Path(sys.argv[2])
begin = sys.argv[3]
end = sys.argv[4]

existing = target.read_text(encoding="utf-8") if target.exists() else ""
snippet = snippet_path.read_text(encoding="utf-8").strip()
pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)

if pattern.search(existing):
    merged = pattern.sub(snippet, existing, count=1)
else:
    prefix = existing.rstrip()
    merged = (prefix + "\n\n" if prefix else "") + snippet + "\n"

target.write_text(merged.rstrip() + "\n", encoding="utf-8")
PY

echo "[OK] Managed AGENTS block merged: $AGENTS_TARGET"

if [[ "$STRICT" -eq 1 ]]; then
  if [[ -f "$CONFIG_TARGET" ]]; then
    cp "$CONFIG_TARGET" "$CONFIG_TARGET.before-single-luna-v1.1.0-$STAMP.bak"
  fi

  python3 - "$CONFIG_TARGET" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8") if path.exists() else ""

def set_section_keys(text: str, section: str, keys: list[tuple[str, str]]) -> str:
    lines = text.splitlines()
    header = f"[{section}]"

    try:
        start = next(i for i, line in enumerate(lines) if line.strip() == header)
    except StopIteration:
        nested = f"[{section}."
        insert_at = next((i for i, line in enumerate(lines) if line.strip().startswith(nested)), len(lines))
        block = [header] + [f"{k} = {v}" for k, v in keys] + [""]
        lines[insert_at:insert_at] = block
        return "\n".join(lines).rstrip() + "\n"

    end = len(lines)
    for i in range(start + 1, len(lines)):
        if re.match(r"^\s*\[.*\]\s*$", lines[i]):
            end = i
            break

    for key, value in keys:
        rx = re.compile(r"^\s*" + re.escape(key) + r"\s*=")
        found = next((i for i in range(start + 1, end) if rx.match(lines[i])), None)
        if found is not None:
            lines[found] = f"{key} = {value}"
        else:
            lines.insert(end, f"{key} = {value}")
            end += 1

    return "\n".join(lines).rstrip() + "\n"

text = set_section_keys(text, "features", [
    ("multi_agent", "true"),
])

text = set_section_keys(text, "agents", [
    ("enabled", "true"),
    ("max_concurrent_threads_per_session", "1"),
    ("default_subagent_model", '"gpt-5.6-luna"'),
    ("default_subagent_reasoning_effort", '"max"'),
])

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(text, encoding="utf-8")
PY

  echo "[OK] Strict Single-Luna config merged: $CONFIG_TARGET"
else
  echo "[OK] config.toml left unchanged."
fi

echo "[OK] hooks.json untouched."
echo
echo "Installation complete."
echo 'Fully restart Codex, start a NEW session, and invoke:'
echo '  $single-luna-orchestrator'
