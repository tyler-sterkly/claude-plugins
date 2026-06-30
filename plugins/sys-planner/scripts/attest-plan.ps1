# sys-planner: SHA-256 fingerprint PLAN.md and write .attestation.
# PowerShell equivalent of attest-plan.sh for Windows-native callers.
# Usage: .\attest-plan.ps1 [<plan-dir>]

param(
    [string]$PlanDir = ""
)

$ErrorActionPreference = "Stop"

function Resolve-PlanDir {
    $slugRe = '^[A-Za-z0-9_][A-Za-z0-9._-]*$'

    if ($env:PLAN_ID -and $env:PLAN_ID -match $slugRe -and (Test-Path ".plans/$($env:PLAN_ID)" -PathType Container)) {
        return ".plans/$($env:PLAN_ID)"
    }

    if (Test-Path ".plans/.active_plan") {
        $ap = (Get-Content ".plans/.active_plan" -Raw).Trim()
        if ($ap -match $slugRe -and (Test-Path ".plans/$ap" -PathType Container)) {
            return ".plans/$ap"
        }
    }

    if (Test-Path ".plans" -PathType Container) {
        $newest = $null; $newestTime = [DateTime]::MinValue
        foreach ($d in Get-ChildItem ".plans" -Directory) {
            if ($d.Name -notmatch $slugRe) { continue }
            if (-not (Test-Path "$($d.FullName)/PLAN.md")) { continue }
            if ($d.LastWriteTime -gt $newestTime) { $newestTime = $d.LastWriteTime; $newest = $d.FullName }
        }
        if ($newest) { return $newest }
    }

    if (Test-Path ".plans/PLAN.md") { return ".plans" }
    return $null
}

# Resolve directory
if (-not $PlanDir) {
    $PlanDir = Resolve-PlanDir
}
if (-not $PlanDir -or -not (Test-Path $PlanDir -PathType Container)) {
    Write-Error "[sys-planner] No active plan directory found. Create .plans/PLAN.md first."
    exit 1
}

$planFile = Join-Path $PlanDir "PLAN.md"
$attestFile = Join-Path $PlanDir ".attestation"

if (-not (Test-Path $planFile)) {
    Write-Error "[sys-planner] $planFile not found."
    exit 1
}

# Compute SHA-256
$hash = (Get-FileHash $planFile -Algorithm SHA256).Hash.ToLower()
Set-Content -Path $attestFile -Value $hash -NoNewline

Write-Host "[sys-planner] Attested: $planFile"
Write-Host "  SHA-256: $hash"
Write-Host "  Written to: $attestFile"
Write-Host ""
Write-Host "[sys-planner] Hooks will now block injection if PLAN.md changes unexpectedly."
Write-Host "Re-run /plan-attest after any intentional edit to PLAN.md."
