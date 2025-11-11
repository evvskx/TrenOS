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
        return $false
    }
    
    if ($isEducation -or $isEnterprise) {
        return $false
    }
    
    if (-not $isCorrectVersion) {
        return $false
    }
    
    if (-not $isAllowedSKU) {
        return $false
    }
    
    return $true
}

function Test-DiskSpace {
    $systemDrive = $env:SystemDrive
    try {
        $drive = Get-PSDrive -Name $systemDrive[0] -ErrorAction Stop
        $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
        $requiredSpaceGB = 10
        
        if ($freeSpaceGB -ge $requiredSpaceGB) {
            return $true
        } else {
            return $false
        }
    }
    catch {
        return $false
    }
}

function Test-PowerShellVersion {
    $currentVersion = $PSVersionTable.PSVersion
    $requiredVersion = [version]"5.1"
    
    if ($currentVersion -ge $requiredVersion) {
        return $true
    } else {
        return $false
    }
}

function Test-Architecture {
    $is64Bit = [Environment]::Is64BitOperatingSystem
    
    if ($is64Bit) {
        return $true
    } else {
        return $false
    }
}

function Invoke-TrenDependenciesCheck {
    
    $results = @{}
    $allPassed = $true
    
    $results.Administrator = Test-Administrator
    if (-not $results.Administrator) { 
        $allPassed = $false
        
        $scriptPath = $Script:PSCommandPath

        Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList "/c powershell -ExecutionPolicy Bypass -File `"$scriptPath`" && timeout /nobreak 10 > nul"
    
        Write-TrenLog "ERROR: Administrator privileges are required."
        Exit
    }

    $results.WindowsEdition = Test-WindowsEdition
    if (-not $results.WindowsEdition) { $allPassed = $false }
    
    $results.DiskSpace = Test-DiskSpace
    if (-not $results.DiskSpace) { $allPassed = $false }
    
    $results.PowerShell = Test-PowerShellVersion
    if (-not $results.PowerShell) { $allPassed = $false }
    
    $results.Architecture = Test-Architecture
    if (-not $results.Architecture) { $allPassed = $false }
    
    foreach ($check in $results.Keys) {
        $status = if ($results[$check]) { $true } else { $false }
        if (-not $status) {
            Write-TrenLog "$check : $status"
        }
    }
    
    return $allPassed
}

return Invoke-TrenDependenciesCheck