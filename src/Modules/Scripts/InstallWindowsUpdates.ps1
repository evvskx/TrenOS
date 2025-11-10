function InstallWindowsUpdates {
    Write-TrenLog "Starting Windows Updates installation..."
    
    # install dependencies
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-TrenLog "Installing PSWindowsUpdate module..."
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    }
    
    Import-Module PSWindowsUpdate
    Write-TrenLog "PSWindowsUpdate module imported successfully"
    
    # start service
    $svc = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.StartType -eq 'Disabled') {
            Write-TrenLog "Enabling Windows Update service..."
            Set-Service wuauserv -StartupType Manual
        }
        if ($svc.Status -ne 'Running') {
            Write-TrenLog "Starting Windows Update service..."
            Start-Service wuauserv
        }
        Write-TrenLog "Windows Update service is ready"
    }
    
    # get available updates
    Write-TrenLog "Checking for available updates..."
    $updates = Get-WindowsUpdate -ErrorAction SilentlyContinue
    
    if (-not $updates -or $updates.Count -eq 0) {
        Write-TrenLog "No Windows updates available"
        return $true
    }
    
    Write-TrenLog "Found $($updates.Count) update(s) to install"
    
    Write-Host "`nUpdates to be installed:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $updates.Count; $i++) {
        $update = $updates[$i]
        $kbNumber = if ($update.KB -ne "") { $update.KB } else { "Unknown" }
        Write-Host "  $($i + 1). [$kbNumber] $($update.Title)" -ForegroundColor Gray
    }
    Write-Host ""
    
    # install updates
    Write-Host "Installation Progress:" -ForegroundColor Yellow
    
    $installResult = Install-WindowsUpdate -AcceptAll -IgnoreReboot -Hide -ErrorAction SilentlyContinue | Out-Null
    
    if ($installResult) {
        $successCount = ($installResult | Where-Object { $_.Status -eq "Installed" }).Count
        $failedCount = $updates.Count - $successCount
       
        $finalPercentage = if ($updates.Count -gt 0) { [math]::Round(($successCount / $updates.Count) * 100) } else { 100 }
        $progressBar = Build-ProgressBar -Percentage $finalPercentage
        
        Write-Host "`r$progressBar - Completed: $successCount/$($updates.Count) updates" -ForegroundColor Green
        Write-Host ""
        
        Write-TrenLog "Installation completed: $successCount successful, $failedCount failed"
        
        # verbose
        if ($failedCount -gt 0) {
            Write-Host "Installation Summary:" -ForegroundColor Yellow
            foreach ($result in $installResult) {
                $statusColor = if ($result.Status -eq "Installed") { "Green" } else { "Red" }
                $kb = if ($result.KB -ne "") { $result.KB } else { "Unknown" }
                Write-Host "  [$kb] - $($result.Status)" -ForegroundColor $statusColor
            }
        }
        
        return ($failedCount -eq 0)
    } else {
        Write-TrenLog "Failed to install Windows updates"
        return $false
    }
}

function Build-ProgressBar {
    param(
        [int]$Percentage,
        [int]$Width = 20
    )
    
    $completedBlocks = [math]::Round(($Percentage / 100) * $Width)
    $remainingBlocks = $Width - $completedBlocks
    
    $color = if ($Percentage -lt 50) { "Yellow" } elseif ($Percentage -lt 100) { "Cyan" } else { "Green" }
    
    $progressBar = "["
    $progressBar += "$([char]27)[92m" + "=" * $completedBlocks + "$([char]27)[0m" 
    $progressBar += "$([char]27)[90m" + " " * $remainingBlocks + "$([char]27)[0m"  
    $progressBar += "]"
    $progressBar += " $Percentage%"
    
    return $progressBar
}

return InstallWindowsUpdates