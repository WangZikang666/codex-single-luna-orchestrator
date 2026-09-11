[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillTarget = Join-Path $CodexHome "skills\single-luna-orchestrator"
$AgentsTarget = Join-Path $CodexHome "AGENTS.md"

$BeginMarker = "<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->"
$EndMarker = "<!-- END SINGLE-LUNA-ORCHESTRATOR -->"

Write-Host "=== Single-Luna Orchestrator uninstaller ===" -ForegroundColor Cyan
Write-Host "hooks.json will not be read, written, or modified." -ForegroundColor Yellow

if (Test-Path $SkillTarget) {
    Remove-Item -LiteralPath $SkillTarget -Recurse -Force
    Write-Host "[OK] Removed skill: $SkillTarget" -ForegroundColor Green
} else {
    Write-Host "[OK] Skill not installed."
}

if (Test-Path $AgentsTarget) {
    $Text = Get-Content -LiteralPath $AgentsTarget -Raw -Encoding UTF8
    $Pattern = "(?s)" + [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)
    $Updated = [regex]::Replace($Text, $Pattern, "").Trim()

    if ($Updated.Length -gt 0) {
        Set-Content -LiteralPath $AgentsTarget -Value ($Updated + "`r`n") -Encoding UTF8
    } else {
        Remove-Item -LiteralPath $AgentsTarget -Force
    }

    Write-Host "[OK] Removed managed AGENTS block." -ForegroundColor Green
}

Write-Host ""
Write-Host "config.toml was intentionally left unchanged." -ForegroundColor Yellow
Write-Host "If Strict mode was used, restore a timestamped backup or edit the Single-Luna keys manually."
Write-Host "hooks.json untouched." -ForegroundColor Green
