[CmdletBinding()]
param(
    [switch]$StrictSingleChild
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillSource = Join-Path $RepoRoot "skills\single-luna-orchestrator"
$SnippetSource = Join-Path $RepoRoot "integration\AGENTS.snippet.md"
$SkillTarget = Join-Path $CodexHome "skills\single-luna-orchestrator"
$AgentsTarget = Join-Path $CodexHome "AGENTS.md"
$ConfigTarget = Join-Path $CodexHome "config.toml"
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

$BeginMarker = "<!-- BEGIN SINGLE-LUNA-ORCHESTRATOR -->"
$EndMarker = "<!-- END SINGLE-LUNA-ORCHESTRATOR -->"

function Backup-File {
    param([string]$Path)
    if (Test-Path $Path) {
        $Backup = "$Path.before-single-luna-v1.1.0-$Stamp.bak"
        Copy-Item -LiteralPath $Path -Destination $Backup -Force
        Write-Host "Backup: $Backup" -ForegroundColor DarkGray
    }
}

function Merge-MarkedBlock {
    param(
        [string]$TargetPath,
        [string]$BlockText
    )

    $Existing = if (Test-Path $TargetPath) {
        Get-Content -LiteralPath $TargetPath -Raw -Encoding UTF8
    } else {
        ""
    }

    $Pattern = "(?s)\Q$BeginMarker\E.*?\Q$EndMarker\E"
    # .NET regex does not support \Q...\E. Escape explicitly.
    $Pattern = "(?s)" + [regex]::Escape($BeginMarker) + ".*?" + [regex]::Escape($EndMarker)

    if ([regex]::IsMatch($Existing, $Pattern)) {
        $Merged = [regex]::Replace($Existing, $Pattern, [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            return $BlockText.TrimEnd()
        }, 1)
    } else {
        $Prefix = $Existing.TrimEnd()
        if ($Prefix.Length -gt 0) {
            $Merged = $Prefix + "`r`n`r`n" + $BlockText.TrimEnd() + "`r`n"
        } else {
            $Merged = $BlockText.TrimEnd() + "`r`n"
        }
    }

    Set-Content -LiteralPath $TargetPath -Value $Merged -Encoding UTF8
}

function Set-TomlSectionKeys {
    param(
        [string]$Text,
        [string]$Section,
        [hashtable]$Keys
    )

    $newline = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($Text -split "`r?`n", 0, "RegexMatch")) {
        $lines.Add($line)
    }

    $sectionHeader = "[$Section]"
    $sectionIndex = -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq $sectionHeader) {
            $sectionIndex = $i
            break
        }
    }

    if ($sectionIndex -lt 0) {
        $nestedPrefix = "[$Section."
        $insertAt = $lines.Count

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim().StartsWith($nestedPrefix)) {
                $insertAt = $i
                break
            }
        }

        $block = [System.Collections.Generic.List[string]]::new()
        $block.Add($sectionHeader)
        foreach ($key in $Keys.Keys) {
            $block.Add("$key = $($Keys[$key])")
        }
        $block.Add("")

        for ($j = $block.Count - 1; $j -ge 0; $j--) {
            $lines.Insert($insertAt, $block[$j])
        }

        return (($lines -join $newline).TrimEnd() + $newline)
    }

    $sectionEnd = $lines.Count
    for ($i = $sectionIndex + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -match '^\[.*\]$') {
            $sectionEnd = $i
            break
        }
    }

    foreach ($key in $Keys.Keys) {
        $pattern = '^\s*' + [regex]::Escape($key) + '\s*='
        $found = -1
        for ($i = $sectionIndex + 1; $i -lt $sectionEnd; $i++) {
            if ($lines[$i] -match $pattern) {
                $found = $i
                break
            }
        }

        if ($found -ge 0) {
            $lines[$found] = "$key = $($Keys[$key])"
        } else {
            $lines.Insert($sectionEnd, "$key = $($Keys[$key])")
            $sectionEnd++
        }
    }

    return (($lines -join $newline).TrimEnd() + $newline)
}

Write-Host "=== Single-Luna Orchestrator v1.1.0 installer ===" -ForegroundColor Cyan
Write-Host "Codex home: $CodexHome"
Write-Host "Strict single-child config: $StrictSingleChild"
Write-Host "hooks.json will not be read, written, or modified." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $SkillSource)) {
    throw "Missing skill source: $SkillSource"
}
if (-not (Test-Path $SnippetSource)) {
    throw "Missing AGENTS snippet: $SnippetSource"
}

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $SkillTarget) | Out-Null

Backup-File $AgentsTarget

if (Test-Path $SkillTarget) {
    $SkillBackup = "$SkillTarget.before-single-luna-v1.1.0-$Stamp"
    Copy-Item -LiteralPath $SkillTarget -Destination $SkillBackup -Recurse -Force
    Remove-Item -LiteralPath $SkillTarget -Recurse -Force
    Write-Host "Backup: $SkillBackup" -ForegroundColor DarkGray
}

Copy-Item -LiteralPath $SkillSource -Destination $SkillTarget -Recurse -Force
Write-Host "[OK] Skill installed: $SkillTarget" -ForegroundColor Green

$Snippet = Get-Content -LiteralPath $SnippetSource -Raw -Encoding UTF8
Merge-MarkedBlock -TargetPath $AgentsTarget -BlockText $Snippet
Write-Host "[OK] Managed AGENTS block merged: $AgentsTarget" -ForegroundColor Green

if ($StrictSingleChild) {
    Backup-File $ConfigTarget

    $Config = if (Test-Path $ConfigTarget) {
        Get-Content -LiteralPath $ConfigTarget -Raw -Encoding UTF8
    } else {
        ""
    }

    $Config = Set-TomlSectionKeys -Text $Config -Section "features" -Keys ([ordered]@{
        multi_agent = "true"
    })

    $Config = Set-TomlSectionKeys -Text $Config -Section "agents" -Keys ([ordered]@{
        enabled = "true"
        max_concurrent_threads_per_session = "1"
        default_subagent_model = '"gpt-5.6-luna"'
        default_subagent_reasoning_effort = '"max"'
    })

    Set-Content -LiteralPath $ConfigTarget -Value $Config -Encoding UTF8
    Write-Host "[OK] Strict Single-Luna config merged: $ConfigTarget" -ForegroundColor Green
} else {
    Write-Host "[OK] config.toml left unchanged." -ForegroundColor Green
}

Write-Host "[OK] hooks.json untouched." -ForegroundColor Green
Write-Host ""
Write-Host "Installation complete." -ForegroundColor Cyan
Write-Host "Fully restart Codex, start a NEW session, and invoke:"
Write-Host '  $single-luna-orchestrator' -ForegroundColor Yellow
