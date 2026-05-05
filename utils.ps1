function update {
    param (
        [switch]$Disk
    )
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Execute this script as administrator!" -ForegroundColor Red
        exit
    }

    Write-Host "`n=== Cleaning temporary files ===" -ForegroundColor Cyan

    $tempPaths = @(
        "$env:TEMP\*",
        "$env:LOCALAPPDATA\Temp\*",
        "C:\Windows\Temp\*"
    )

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "Pulito: $path" -ForegroundColor Green
            }
            catch {
                Write-Host "Error on $path : $_" -ForegroundColor Yellow
            }
        }
    }

    if ($Disk) {
        Write-Host "`n=== Advanced Disk Cleaning ===" -ForegroundColor Cyan
        try {
            Write-Host "Running disk cleaning with cleanmgr..." -ForegroundColor Yellow
            
            $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
            $Caches = Get-ChildItem -Path $RegistryKey
            foreach ($Cache in $Caches) {
                Set-ItemProperty -Path $Cache.PSPath -Name "StateFlags0100" -Value 2 -Type DWord -ErrorAction SilentlyContinue
            }

            Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:100" -Wait -NoNewWindow
            Write-Host "Disk cleaning completed." -ForegroundColor Green
        }
        catch {
            Write-Host "Error during disk cleaning: $_" -ForegroundColor Red
        }
    }

    Write-Host "`n=== Checking Windows updates ===" -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate..." -ForegroundColor Yellow
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    }

    Import-Module PSWindowsUpdate

    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll -IgnoreReboot

    Write-Host "`n=== Checking app updates ===" -ForegroundColor Cyan

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget upgrade --all --accept-package-agreements --accept-source-agreements --silent
    }
    else {
        Write-Host "winget not found." -ForegroundColor Red
    }

    Write-Host "`n=== Everything done ===" -ForegroundColor Green
}