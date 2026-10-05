[CmdletBinding()]
param(
    [string]$Repository = 'zyxel-lyn/TA-Builder',
    [string]$Destination = (Join-Path $env:TEMP 'TA-Builder-Install')
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host 'Administrator privileges are required. Requesting elevation...'
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"' + $scriptPath + '"'),
        '-Repository', ('"' + $Repository + '"'),
        '-Destination', ('"' + $Destination + '"')
    )

    $process = Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -Wait -PassThru
    exit $process.ExitCode
}

if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
}

New-Item -ItemType Directory -Path $Destination -Force | Out-Null

$latestUrl = "https://github.com/$Repository/releases/latest"
Write-Host "Resolving latest release from $Repository..."

$response = Invoke-WebRequest -Uri $latestUrl -UseBasicParsing
$resolvedUrl = $response.BaseResponse.ResponseUri.AbsoluteUri

if ($resolvedUrl -notmatch '/releases/tag/([^/?#]+)$') {
    throw "Could not resolve the latest release tag from $resolvedUrl"
}

$tag = [Uri]::UnescapeDataString($matches[1])
$zipName = "TA-Builder-$tag-Windows-x64.zip"
$zipUrl = "https://github.com/$Repository/releases/download/$tag/$zipName"
$checksumUrl = "https://github.com/$Repository/releases/download/$tag/SHA256SUMS.txt"

$zipPath = Join-Path $Destination $zipName
$checksumsPath = Join-Path $Destination 'SHA256SUMS.txt'
$extractPath = Join-Path $Destination 'bundle'

Write-Host "Latest release: $tag"
Write-Host "Downloading $zipName..."

Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
Invoke-WebRequest -Uri $checksumUrl -OutFile $checksumsPath -UseBasicParsing

$fileName = [IO.Path]::GetFileName($zipPath)
$line = Get-Content -LiteralPath $checksumsPath |
    Where-Object { $_ -match ('^[A-Fa-f0-9]{64}\s+\*?' + [regex]::Escape($fileName) + '$') } |
    Select-Object -First 1

if (-not $line) {
    throw "Checksum entry not found for $fileName"
}

$expected = ($line -split '\s+')[0].ToUpperInvariant()
$actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()

if ($actual -ne $expected) {
    throw "SHA-256 verification failed. Expected $expected but received $actual."
}

Write-Host 'SHA-256 verification passed.'
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

$installer = Get-ChildItem -LiteralPath $extractPath -Filter 'Install-PA-Builder.ps1' -File -Recurse |
    Select-Object -First 1

if (-not $installer) {
    throw 'Install-PA-Builder.ps1 was not found in the release bundle.'
}

Write-Host 'Launching validated bundle installer...'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer.FullName -BundleDirectory $installer.DirectoryName

if ($LASTEXITCODE -ne 0) {
    throw "Bundle installer failed with exit code $LASTEXITCODE."
}

Write-Host 'TA Builder installation completed successfully.'
Write-Output "RELEASE=$tag"
Write-Output "SHA256=$actual"
Write-Output 'INSTALL=PASS'
