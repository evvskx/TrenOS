function Test-WindowsEdition {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    if (-not $os) {
        return $false
    }
    
    $caption = $os.Caption
    $edition = $os.OperatingSystemSKU

    
    $allowedSKUs = @(48, 101)  # Pro, Home
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
    $architecture = $env:PROCESSOR_ARCHITECTURE
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
    
    $results.WindowsEdition = Test-WindowsEdition
    if (-not $results.WindowsEdition) { $allPassed = $false }
    
    $results.DiskSpace = Test-DiskSpace
    if (-not $results.DiskSpace) { $allPassed = $false }
    
    $results.PowerShell = Test-PowerShellVersion
    if (-not $results.PowerShell) { $allPassed = $false }
    
    $results.Architecture = Test-Architecture
    if (-not $results.Architecture) { $allPassed = $false }
    
    $passedCount = ($results.GetEnumerator() | Where-Object Value).Count
    $totalCount = $results.Count
    
    
    foreach ($result in $results.GetEnumerator()) {
        $status = if ($result.Value) { "PASS" } else { "FAIL" }
        $color = if ($result.Value) { "Green" } else { "Red" }
    }
    
    if ($allPassed) {
    } else {
    }
    
    return $allPassed
}

return Invoke-TrenDependenciesCheck