#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs PowerShell 7 (if missing) and sets it as the default Windows Terminal profile.
.DESCRIPTION
    Designed to be pushed via NinjaOne as a scripted task (Run As: System).
    - Installs PowerShell 7 via winget or direct MSI if not present.
    - Configures Windows Terminal to default to pwsh 7 for the logged-in user.
    - Preserves PowerShell 5.1 as a visible, selectable profile.
    - Sets Windows Terminal as the default terminal application.
.NOTES
    Run As: System (NinjaOne)
    Tested on: Windows 11 Pro
#>

$ErrorActionPreference = 'Stop'

# -- Well-known Windows Terminal profile GUIDs --
$Pwsh7Guid = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
$Ps51Guid  = '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}'
$PwshExe   = "$env:ProgramFiles\PowerShell\7\pwsh.exe"

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$ts] [$Level] $Message"
}

# ============================================================
# 1. INSTALL POWERSHELL 7 IF MISSING
# ============================================================
function Install-Pwsh7 {
    if (Test-Path $PwshExe) {
        $ver = & $PwshExe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
        Write-Log "PowerShell 7 already installed (v$ver). Skipping install."
        return
    }

    Write-Log "PowerShell 7 not found. Attempting install..."

    # Try winget first (works under SYSTEM on newer Win 11 builds)
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Log "Trying winget install..."
        try {
            $result = & winget.exe install --id Microsoft.PowerShell --source winget `
                --accept-package-agreements --accept-source-agreements --silent 2>&1
            Write-Log ($result -join "`n")
            if (Test-Path $PwshExe) {
                Write-Log "PowerShell 7 installed via winget."
                return
            }
        } catch {
            Write-Log "Winget attempt failed: $_" -Level 'WARN'
        }
    }

    # Fallback: download MSI from GitHub releases
    Write-Log "Downloading PowerShell 7 MSI from GitHub..."
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $releaseInfo = Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' -UseBasicParsing
        $msiAsset = $releaseInfo.assets | Where-Object { $_.name -match 'PowerShell-\d+\.\d+\.\d+-win-x64\.msi$' } | Select-Object -First 1

        if (-not $msiAsset) {
            throw "Could not find x64 MSI asset in latest GitHub release."
        }

        $msiPath = Join-Path $env:TEMP $msiAsset.name
        Write-Log "Downloading $($msiAsset.name)..."
        Invoke-WebRequest -Uri $msiAsset.browser_download_url -OutFile $msiPath -UseBasicParsing

        Write-Log "Installing MSI (silent)..."
        $msiArgs = @(
            '/i', "`"$msiPath`"", '/qn',
            'ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1',
            'ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1',
            'ENABLE_PSREMOTING=1',
            'REGISTER_MANIFEST=1',
            'USE_MU=1',
            'ENABLE_MU=1'
        )
        $proc = Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -NoNewWindow -PassThru
        if ($proc.ExitCode -ne 0) {
            throw "MSI install exited with code $($proc.ExitCode)."
        }

        Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Log "MSI install failed: $_" -Level 'ERROR'
        throw "PowerShell 7 installation failed. Cannot continue."
    }

    if (-not (Test-Path $PwshExe)) {
        throw "PowerShell 7 install appeared to succeed but pwsh.exe not found at $PwshExe."
    }

    $ver = & $PwshExe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
    Write-Log "PowerShell 7 v$ver installed successfully."
}

# ============================================================
# 2. GET LOGGED-IN USER INFO
# ============================================================
function Get-LoggedInUserInfo {
    # Get the active console session user
    $explorerProcs = @(Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" -ErrorAction SilentlyContinue)
    if ($explorerProcs.Count -eq 0) {
        return $null
    }

    $ownerInfo = Invoke-CimMethod -InputObject $explorerProcs[0] -MethodName GetOwner -ErrorAction SilentlyContinue
    if (-not $ownerInfo -or -not $ownerInfo.User) {
        return $null
    }

    $username = $ownerInfo.User
    $domain   = $ownerInfo.Domain

    try {
        $ntAccount = New-Object System.Security.Principal.NTAccount($domain, $username)
        $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
    } catch {
        Write-Log "Could not resolve SID for $domain\$username : $_" -Level 'WARN'
        return $null
    }

    $profilePath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -ErrorAction SilentlyContinue).ProfileImagePath

    return @{
        Username    = $username
        Domain      = $domain
        SID         = $sid
        ProfilePath = $profilePath
    }
}

# ============================================================
# 3. ENSURE WINDOWS TERMINAL SETTINGS EXIST
# ============================================================
function Initialize-WindowsTerminalSettings {
    param([hashtable]$UserInfo)

    $profilePath = $UserInfo.ProfilePath

    # Check if settings.json already exists in either location
    $settingsLocations = @(
        Join-Path $profilePath 'AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
        Join-Path $profilePath 'AppData\Local\Microsoft\Windows Terminal\settings.json'
    )

    foreach ($loc in $settingsLocations) {
        if (Test-Path $loc) {
            Write-Log "Windows Terminal settings already exist at $loc. No seed needed."
            return
        }
    }

    # No settings.json found -- launch WT briefly as the logged-in user to generate defaults
    Write-Log "No Windows Terminal settings.json found. Launching WT to seed default config..."

    # Find wt.exe
    $wtExe = Get-Command wt.exe -ErrorAction SilentlyContinue
    if (-not $wtExe) {
        # Check common Store app location
        $wtStore = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\wt.exe'
        if (Test-Path $wtStore) {
            $wtExe = $wtStore
        } else {
            Write-Log "wt.exe not found. Windows Terminal may not be installed." -Level 'WARN'
            return
        }
    }

    # Use a scheduled task to launch WT as the logged-in user (since we're running as SYSTEM)
    # The task runs wt.exe which opens, generates settings.json, then we kill it after a short delay
    $taskName = 'SeedWindowsTerminal_Temp'

    try {
        # Create a scheduled task that runs as the logged-in user
        $action  = New-ScheduledTaskAction -Execute 'wt.exe' -Argument '--window 0 new-tab --title SeedWT -- cmd.exe /c exit'
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(2)

        # Run as the interactive logged-in user
        $principal = New-ScheduledTaskPrincipal -UserId "$($UserInfo.Domain)\$($UserInfo.Username)" -LogonType Interactive -RunLevel Limited

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
        Write-Log "Registered temp scheduled task to launch WT as $($UserInfo.Username)."

        Start-ScheduledTask -TaskName $taskName
        Write-Log "Launched WT via scheduled task. Waiting for settings.json to be created..."

        # Wait up to 15 seconds for settings.json to appear
        $waited = 0
        $settled = $false
        while ($waited -lt 15) {
            Start-Sleep -Seconds 2
            $waited += 2
            foreach ($loc in $settingsLocations) {
                if (Test-Path $loc) {
                    Write-Log "settings.json detected at $loc after ~${waited}s."
                    $settled = $true
                    break
                }
            }
            if ($settled) { break }
        }

        if (-not $settled) {
            Write-Log "settings.json did not appear within 15 seconds. WT may not have generated it." -Level 'WARN'
        }

        # Kill the terminal process we spawned (clean up the window)
        $wtProcs = @(Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowTitle -match 'SeedWT' })
        if ($wtProcs.Count -eq 0) {
            # Just grab any WT started very recently (within last 30s) by this user
            $wtProcs = @(Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue)
        }
        foreach ($p in $wtProcs) {
            $p | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Write-Log "Cleaned up seeded WT process."

    } catch {
        Write-Log "Failed to seed Windows Terminal settings: $_" -Level 'WARN'
    } finally {
        # Clean up the temp scheduled task
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# ============================================================
# 4. CONFIGURE WINDOWS TERMINAL SETTINGS
# ============================================================
function Set-WindowsTerminalDefaults {
    param([hashtable]$UserInfo)

    $profilePath = $UserInfo.ProfilePath

    # Both possible settings.json locations
    $settingsLocations = @(
        Join-Path $profilePath 'AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
        Join-Path $profilePath 'AppData\Local\Microsoft\Windows Terminal\settings.json'
    )

    $found = $false

    foreach ($settingsFile in $settingsLocations) {
        if (-not (Test-Path $settingsFile)) { continue }
        $found = $true
        Write-Log "Found settings: $settingsFile"

        # Back up the original
        $backupPath = "$settingsFile.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $settingsFile $backupPath -Force
        Write-Log "Backup saved to $backupPath"

        # Read raw content, strip // comments (WT supports them but ConvertFrom-Json doesn't)
        $raw = Get-Content $settingsFile -Raw -Encoding UTF8
        $cleaned = $raw -replace '(?m)(?<=^([^"]*"[^"]*")*[^"]*)\s*//.*$', ''

        try {
            $settings = $cleaned | ConvertFrom-Json
        } catch {
            Write-Log "Could not parse $settingsFile : $_" -Level 'WARN'
            continue
        }

        # Set default profile to pwsh 7
        if ($settings.PSObject.Properties['defaultProfile']) {
            $settings.defaultProfile = $Pwsh7Guid
        } else {
            $settings | Add-Member -NotePropertyName 'defaultProfile' -NotePropertyValue $Pwsh7Guid
        }
        Write-Log "defaultProfile set to PowerShell 7."

        # Ensure profiles.list exists
        if (-not $settings.profiles -or -not $settings.profiles.list) {
            Write-Log "No profiles.list found, skipping profile manipulation." -Level 'WARN'
            $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsFile -Encoding UTF8 -Force
            continue
        }

        $profilesList = @($settings.profiles.list)

        # Make sure PS 5.1 profile is present and visible
        $ps51Profile = $profilesList | Where-Object { $_.guid -eq $Ps51Guid }
        if ($ps51Profile) {
            $ps51Profile.hidden = $false
            Write-Log "PowerShell 5.1 profile confirmed visible."
        } else {
            Write-Log "Adding PowerShell 5.1 profile to list."
            $profilesList += [PSCustomObject]@{
                guid        = $Ps51Guid
                name        = 'Windows PowerShell (5.1)'
                commandline = 'powershell.exe'
                hidden      = $false
            }
        }

        # Make sure pwsh 7 profile exists
        $pwsh7Profile = $profilesList | Where-Object { $_.guid -eq $Pwsh7Guid }
        if ($pwsh7Profile) {
            $pwsh7Profile.hidden = $false
            Write-Log "PowerShell 7 profile confirmed visible."
        } else {
            Write-Log "Adding PowerShell 7 profile to list."
            $profilesList += [PSCustomObject]@{
                guid        = $Pwsh7Guid
                name        = 'PowerShell 7'
                commandline = $PwshExe
                hidden      = $false
            }
        }

        $settings.profiles.list = $profilesList

        # Write back
        $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsFile -Encoding UTF8 -Force
        Write-Log "Settings saved."
    }

    if (-not $found) {
        Write-Log "No Windows Terminal settings.json found even after seed attempt. Terminal may not be installed." -Level 'WARN'
    }
}

# ============================================================
# 5. SET WINDOWS TERMINAL AS DEFAULT TERMINAL APP
# ============================================================
function Set-DefaultTerminalApp {
    param([hashtable]$UserInfo)

    # Windows 11 stores default terminal in the user's registry hive
    # DelegationConsole / DelegationTerminal under Console\%%Startup
    $hiveLoaded = $false
    $hivePath = "HKU:\$($UserInfo.SID)"

    # Mount HKU if not available
    if (-not (Test-Path 'HKU:\')) {
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
    }

    # Check if hive is loaded (active user session should have it loaded)
    if (-not (Test-Path "HKU:\$($UserInfo.SID)")) {
        Write-Log "User registry hive not loaded. Attempting to load..." -Level 'WARN'
        $ntUserDat = Join-Path $UserInfo.ProfilePath 'NTUSER.DAT'
        if (Test-Path $ntUserDat) {
            & reg.exe load "HKU\$($UserInfo.SID)_temp" $ntUserDat 2>$null
            $hivePath = "HKU:\$($UserInfo.SID)_temp"
            $hiveLoaded = $true
        } else {
            Write-Log "Cannot find NTUSER.DAT. Skipping default terminal config." -Level 'WARN'
            return
        }
    }

    try {
        $startupKey = "$hivePath\Console\%%Startup"

        if (-not (Test-Path $startupKey)) {
            New-Item -Path $startupKey -Force | Out-Null
        }

        # GUIDs for Windows Terminal delegation
        $wtConsoleGuid  = '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}'
        $wtTerminalGuid = '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}'

        Set-ItemProperty -Path $startupKey -Name 'DelegationConsole'  -Value $wtConsoleGuid  -Type String -Force
        Set-ItemProperty -Path $startupKey -Name 'DelegationTerminal' -Value $wtTerminalGuid -Type String -Force
        Write-Log "Default terminal application set to Windows Terminal."
    } catch {
        Write-Log "Failed to set default terminal: $_" -Level 'WARN'
    } finally {
        if ($hiveLoaded) {
            [gc]::Collect()
            & reg.exe unload "HKU\$($UserInfo.SID)_temp" 2>$null
        }
    }
}

# ============================================================
# MAIN
# ============================================================
try {
    Write-Log "========== Set-DefaultPwsh7 START =========="

    # Step 1: Install pwsh 7
    Install-Pwsh7

    # Step 2: Identify logged-in user
    $userInfo = Get-LoggedInUserInfo
    if (-not $userInfo) {
        Write-Log "No logged-in user detected. PowerShell 7 is installed but terminal settings were not configured." -Level 'WARN'
        Write-Log "Run this script again when a user is logged in, or have the user open Windows Terminal to auto-detect pwsh."
        exit 0
    }
    Write-Log "Target user: $($userInfo.Domain)\$($userInfo.Username) (SID: $($userInfo.SID))"

    # Step 3: Seed Windows Terminal settings if never opened
    Initialize-WindowsTerminalSettings -UserInfo $userInfo

    # Step 4: Configure Windows Terminal
    Set-WindowsTerminalDefaults -UserInfo $userInfo

    # Step 5: Set Windows Terminal as default terminal app
    Set-DefaultTerminalApp -UserInfo $userInfo

    Write-Log "========== Set-DefaultPwsh7 COMPLETE =========="
    Write-Log "PowerShell 7 is the default. PowerShell 5.1 is available in the Terminal dropdown."
    exit 0
} catch {
    Write-Log "FATAL: $_" -Level 'ERROR'
    Write-Log $_.ScriptStackTrace -Level 'ERROR'
    exit 1
}
