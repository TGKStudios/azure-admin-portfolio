<#
.SYNOPSIS
    Blocks a commit if the staged files contain secrets or values from .secrets-denylist.

.DESCRIPTION
    Runs automatically before every commit (see .githooks/pre-commit). It checks only what is
    staged, which is exactly what the commit would publish. Two kinds of checks:

      1. Patterns that look like secrets: storage account keys, SAS signatures, private keys,
         and passwords or client secrets typed into a file.
      2. Exact values listed in .secrets-denylist, one per line. That file is in .gitignore, so it
         never leaves your machine. Put your tenant ID, subscription ID and real usernames in it.

    Exit code 0 lets the commit continue. Exit code 1 stops it.

.EXAMPLE
    .\tools\Test-NoSecrets.ps1
    Checks the files currently staged with git add.
#>
[CmdletBinding()]
param()

# Each entry: what the problem is called, and a regular expression that finds it.
$patterns = [ordered]@{
    'Storage account key or connection string' = 'AccountKey=[A-Za-z0-9+/=]{20,}'
    'SAS token signature'                       = '[?&]sig=[A-Za-z0-9%+/=]{20,}'
    'Private key'                               = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    'Password typed into the file'              = '(?i)password\s*[:=]\s*[''"][^''"]{6,}[''"]'
    'Client secret typed into the file'         = '(?i)client_?secret\s*[:=]\s*[''"][^''"]{8,}[''"]'
    'Long base64 value shaped like an account key' = '[A-Za-z0-9+/]{86}=='
}

# File types that are never text; scanning them only produces noise.
$binaryExtensions = '.png', '.jpg', '.jpeg', '.gif', '.ico', '.pdf', '.zip', '.docx'

$repoRoot = git rev-parse --show-toplevel
$denyFile = Join-Path $repoRoot '.secrets-denylist'
$deniedValues = @()
if (Test-Path $denyFile) {
    $deniedValues = Get-Content $denyFile |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
}

$stagedFiles = git diff --cached --name-only --diff-filter=ACMR
$findings = foreach ($path in $stagedFiles) {
    if ($binaryExtensions -contains [IO.Path]::GetExtension($path).ToLower()) { continue }

    # ":path" asks Git for the staged copy of the file, not the one on disk.
    $text = (git show ":$path") -join "`n"

    foreach ($problem in $patterns.Keys) {
        if ($text -match $patterns[$problem]) {
            [pscustomobject]@{ File = $path; Problem = $problem }
        }
    }
    foreach ($value in $deniedValues) {
        if ($text.IndexOf($value, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            [pscustomobject]@{ File = $path; Problem = 'Contains a value from .secrets-denylist' }
        }
    }
}

if ($findings) {
    Write-Host 'Commit blocked: these staged files look like they contain secrets.' -ForegroundColor Red
    $findings | Format-Table -AutoSize | Out-String | Write-Host
    Write-Host 'Replace the value with a parameter, run git add on the file again, then commit.'
    exit 1
}
exit 0
