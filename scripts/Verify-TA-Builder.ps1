[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ChecksumsPath
)

$ErrorActionPreference = 'Stop'

$zip = (Resolve-Path -LiteralPath $ZipPath).Path
$checksums = (Resolve-Path -LiteralPath $ChecksumsPath).Path
$fileName = [IO.Path]::GetFileName($zip)

$line = Get-Content -LiteralPath $checksums |
    Where-Object { $_ -match ('^[A-Fa-f0-9]{64}\s+\*?' + [regex]::Escape($fileName) + '$') } |
    Select-Object -First 1

if (-not $line) {
    throw "Checksum entry not found for $fileName"
}

$expected = ($line -split '\s+')[0].ToUpperInvariant()
$actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Output "FILE=$fileName"
Write-Output "EXPECTED_SHA256=$expected"
Write-Output "ACTUAL_SHA256=$actual"

if ($actual -ne $expected) {
    Write-Output 'VERIFY=FAIL'
    exit 1
}

Write-Output 'VERIFY=PASS'
