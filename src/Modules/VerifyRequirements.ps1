function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $true
    } else {
        return $false
    }
}

function Test-WindowsEdition {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    if (-not $os) {
        return $false
    }
    
    $caption = $os.Caption
    $edition = $os.OperatingSystemSKU

    $allowedSKUs = @(48, 101)  # pro, home
    $isAllowedSKU = $edition -in $allowedSKUs
    
    $isWindows10 = $caption -like "*Windows 10*"
    $isWindows11 = $caption -like "*Windows 11*"
    $isCorrectVersion = $isWindows10 -or $isWindows11
    
    $isServer = $caption -like "*Server*"
    $isEducation = $caption -like "*Education*"
    $isEnterprise = $caption -like "*Enterprise*"
    
    
    if ($isServer) {
        Write-TrenLog "Unsupported OS: Windows Server edition detected"
        return $false
    }
    
    if ($isEducation -or $isEnterprise) {
        Write-TrenLog "Unsupported OS: Education or Enterprise edition detected"
        return $false
    }
    
    if (-not $isCorrectVersion) {
        Write-TrenLog "Unsupported OS: Not Windows 10 or Windows 11"
        return $false
    }
    
    if (-not $isAllowedSKU) {
        Write-TrenLog "Unsupported OS: Edition not in allowed SKUs"
        return $false
    }
    
    Write-TrenLog "Windows edition check passed: $caption"
    return $true
}

function Test-DiskSpace {
    $systemDrive = $env:SystemDrive
    try {
        $drive = Get-PSDrive -Name $systemDrive[0] -ErrorAction Stop
        $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
        $requiredSpaceGB = 10
        
        if ($freeSpaceGB -ge $requiredSpaceGB) {
            Write-TrenLog "Disk space check passed: $freeSpaceGB GB free"
            return $true
        } else {
            Write-TrenLog "Disk space check failed: Only $freeSpaceGB GB free (requires $requiredSpaceGB GB)"
            return $false
        }
    }
    catch {
        Write-TrenLog "Disk space check failed: Unable to query drive information"
        return $false
    }
}

function Test-PowerShellVersion {
    $currentVersion = $PSVersionTable.PSVersion
    $requiredVersion = [version]"5.1"
    
    if ($currentVersion -ge $requiredVersion) {
        Write-TrenLog "PowerShell version check passed: $currentVersion"
        return $true
    } else {
        Write-TrenLog "PowerShell version check failed: $currentVersion (requires $requiredVersion)"
        return $false
    }
}

function Test-Architecture {
    $is64Bit = [Environment]::Is64BitOperatingSystem
    
    if ($is64Bit) {
        Write-TrenLog "Architecture check passed: 64-bit system"
        return $true
    } else {
        Write-TrenLog "Architecture check failed: 32-bit system not supported"
        return $false
    }
}

function Invoke-TrenDependenciesCheck {
    Write-TrenLog "Starting system requirements verification..."
    
    $results = @{}
    $allPassed = $true
    
    $results.Administrator = Test-Administrator
    if (-not $results.Administrator) { 
        $allPassed = $false
        
        $scriptPath = $Script:PSCommandPath

        Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList "/c powershell -ExecutionPolicy Bypass -File `"$scriptPath`" && timeout /nobreak 10 > nul"
    
        Write-TrenLog "ERROR: Administrator privileges are required."
        Exit
    } else {
        Write-TrenLog "Administrator check passed: Running with elevated privileges"
    }
    
    $results.WindowsEdition = Test-WindowsEdition
    if (-not $results.WindowsEdition) { $allPassed = $false }
    
    $results.DiskSpace = Test-DiskSpace
    if (-not $results.DiskSpace) { $allPassed = $false }
    
    $results.PowerShell = Test-PowerShellVersion
    if (-not $results.PowerShell) { $allPassed = $false }
    
    $results.Architecture = Test-Architecture
    if (-not $results.Architecture) { $allPassed = $false }
    
    Write-TrenLog "System requirements verification completed:"
    foreach ($check in $results.Keys) {
        $status = if ($results[$check]) { "PASS" } else { "FAIL" }
        $color = if ($results[$check]) { "Green" } else { "Red" }
        Write-Host "                  - $check : " -NoNewline
        Write-Host $status -ForegroundColor $color
    }
    
    return $allPassed
}

return Invoke-TrenDependenciesCheck