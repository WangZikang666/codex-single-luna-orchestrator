[CmdletBinding()]
param(
    [string]$Repo = "WangZikang666/codex-single-luna-orchestrator",
    [switch]$CreateRelease
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is not installed or not on PATH."
}

gh auth status

Write-Host "Configuring repository About/features..." -ForegroundColor Cyan

gh repo edit $Repo `
  --description "Explicit-only Codex orchestration skill: one reusable Luna Max executor, parent-owned reasoning, no hooks or MCP bridge." `
  --enable-issues `
  --enable-discussions `
  --enable-wiki=false `
  --enable-projects=false `
  --enable-squash-merge `
  --enable-merge-commit=false `
  --enable-rebase-merge=false `
  --delete-branch-on-merge `
  --allow-update-branch `
  --add-topic codex `
  --add-topic openai-codex `
  --add-topic agent-orchestration `
  --add-topic multi-agent `
  --add-topic coding-agent `
  --add-topic ai-agents `
  --add-topic developer-tools `
  --add-topic llm `
  --add-topic workflow `
  --add-topic prompt-engineering

Write-Host "Creating/updating useful labels..." -ForegroundColor Cyan

$labels = @(
    @{ Name = "compatibility"; Color = "5319E7"; Description = "Codex runtime/version compatibility" },
    @{ Name = "runtime";       Color = "1D76DB"; Description = "Native Codex runtime behavior" },
    @{ Name = "installer";     Color = "0E8A16"; Description = "Installation or configuration" },
    @{ Name = "documentation"; Color = "0075CA"; Description = "Documentation improvements" },
    @{ Name = "reasoning-boundary"; Color = "D93F0B"; Description = "Parent/Luna decision boundary" }
)

foreach ($label in $labels) {
    gh label create $label.Name `
      --repo $Repo `
      --color $label.Color `
      --description $label.Description `
      --force
}

if ($CreateRelease) {
    $repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
    $notes = Join-Path $repoRoot "docs\RELEASE_NOTES_v1.0.0.md"

    gh release create v1.0.0 `
      --repo $Repo `
      --title "Single-Luna Orchestrator v1.0.0" `
      --notes-file $notes

    Write-Host "[OK] Release v1.0.0 created." -ForegroundColor Green
} else {
    Write-Host "Release not created. Re-run with -CreateRelease after validating Actions." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Repository settings complete." -ForegroundColor Green
Write-Host "Manual recommended steps remain:"
Write-Host "1. Upload a Social Preview image in Settings > General."
Write-Host "2. Enable Private vulnerability reporting in Settings > Security."
Write-Host "3. Add a main-branch ruleset / branch protection after the first push."
