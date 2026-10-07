# Installation Guide

## Windows x64

TA Builder is distributed as a signed MSIX inside a ZIP bundle.

### Manual installation

1. Open the latest release:
   https://github.com/zyxel-lyn/TA-Builder/releases/latest

2. Download:
   - `TA-Builder-v1.1.1-Windows-x64.zip`
   - `SHA256SUMS.txt`

3. Verify the ZIP:

```powershell
Get-FileHash .\TA-Builder-v1.1.1-Windows-x64.zip -Algorithm SHA256
```

Expected SHA-256 for v1.1.1:

```text
5C4DFC9C97DE8D8AB098C342C8BC4A688FA0F084394DA3274A83386074940BAD
```

4. Extract the ZIP.

5. Open PowerShell as Administrator inside the extracted directory.

6. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Install-PA-Builder.ps1
```

7. Open **PA Builder** from the Start Menu.

## Helper installation

From this repository:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-TA-Builder.ps1
```

The helper:

1. resolves the latest GitHub Release;
2. downloads the Windows x64 ZIP and checksum manifest;
3. validates SHA-256;
4. extracts the bundle;
5. launches the bundled installer.

## Uninstall

Use the `Uninstall-PA-Builder.ps1` script bundled with the release, or uninstall **PA Builder** from Windows Settings.

## Trust model

The MSIX is signed with the TA/PA Builder peer-release certificate.

The public certificate is included in the release bundle. The installer adds that certificate to Windows TrustedPeople before installing the MSIX.

The private signing key is never included in the public release.

## Troubleshooting

### PowerShell blocks the script

Use a process-only execution policy:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

This does not permanently change the machine-wide policy.

### Windows reports an untrusted package

Run the bundled installer as Administrator instead of opening the MSIX directly. The installer handles the public certificate trust step.

### Existing installation

A newer compatible MSIX can update an existing installation using the same package identity.
