
$tweaks = ,@(
    @("Creating Restore Point", "Modules/Scripts/CreateSystemRestorePoint.ps1")
    @("Installing Dependencies", "Modules/Scripts/InstallDependencies.ps1")
    @("Installing Windows Updates", "Modules/Scripts/InstallWindowsUpdates.ps1")
    @("Disabling Telemetry", "Modules/Scripts/DisableTelemetry.ps1")
    @("Disabling Background Apps", "Modules/Scripts/DisableBackgroundApps.ps1")
    @("Disabling Visual Effects", "Modules/Scripts/DisableVisualEffects.ps1")
    @("Disabling Activity History", "Modules/Scripts/DisableActivityHistory.ps1")
    @("Disabling GameDVR", "Modules/Scripts/DisableGameDVR.ps1")
    @("Disabling WPBT", "Modules/Scripts/DisableWPBT.ps1")
    @("Disabling Cortana", "Modules/Scripts/DisableCortana.ps1")
    @("Disabling Cloud Sync", "Modules/Scripts/DisableCloudSync.ps1")
    @("Disabling Windows Suggestions", "Modules/Scripts/DisableWindowsSuggestions.ps1")
    @("Tweaking Start Menu", "Modules/Scripts/TweakStartMenu.ps1")
    @("Tweaking Services", "Modules/Scripts/TweakServices.ps1")
    @("Uninstalling Bloatware", "Modules/Scripts/UninstallBloatware.ps1")
    @("Applying Optimized Powerplan", "Modules/Scripts/ApplyCustomPowerplan.ps1")
    @("Optimizing Disk", "Modules/Scripts/OptimizeDisk.ps1")
)

function Optimize {
    param($config)
    
    Write-TrenLog "Starting optimization process..."
    
    foreach ($tweak in $tweaks) {
        $message = $tweak[0]
        $scriptPath = "/" + $tweak[1]
        
        Write-TrenLog $message
        $result = Run-TrenScript -Path $scriptPath -Config $config
        
        if (-not $result) {
            Write-TrenLog "Tweak failed: $message"
        }
    }
    
    Write-TrenLog "Optimization process completed!"
    return 1
}

return (Optimize -config $config)
