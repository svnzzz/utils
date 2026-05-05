# Windows Utils

PowerShell scripts for Windows maintenance and updates.

## Installation

If you don't have a profile yet, create one first:

```powershell
New-Item -Path $profile -ItemType File -Force
```

Then open and edit it:

```powershell
notepad $profile
```
or
```powershell
code $profile
```

Copy the entire `utils.ps1` content and paste it into your profile. Save and restart PowerShell.

## Usage

```powershell
update
```

Run with disk cleanup:

```powershell
update -Disk
```

## Notes

- Requires **Administrator** privileges
- PSWindowsUpdate module is installed automatically on first run
- Requires [winget](https://github.com/microsoft/winget-cli) for app updates
- Temp cleanup:
  - `$env:TEMP`
  - `$env:LOCALAPPDATA\Temp`
  - `C:\Windows\Temp`

## Requirements

- Windows 10/11
- PowerShell 5.1+
- Administrator rights
- Internet connection