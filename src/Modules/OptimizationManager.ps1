$tweaks = @(
    @{ Message = "Creating Restore Point"; Script = "Modules/Scripts/CreateSystemRestorePoint.ps1" }
    @{ Message = "Installing Dependencies"; Script = "Modules/Scripts/InstallDependencies.ps1" }
    @{ Message = "Installing Windows Updates"; Script = "Modules/Scripts/InstallWindowsUpdates.ps1" }
    @{ Message = "Optimizing Disk"; Script = "Modules/Scripts/OptimizeDisk.ps1" }
    @{ Message = "Disabling Telemetry"; Script = "Modules/Scripts/DisableTelemetry.ps1" }
    @{ Message = "Disabling Background Apps"; Script = "Modules/Scripts/DisableBackgroundApps.ps1" }
    @{ Message = "Disabling Visual Effects"; Script = "Modules/Scripts/DisableVisualEffects.ps1" }
    @{ Message = "Disabling Activity History"; Script = "Modules/Scripts/DisableActivityHistory.ps1" }
    @{ Message = "Disabling GameDVR"; Script = "Modules/Scripts/DisableGameDVR.ps1" }
    @{ Message = "Disabling WPBT"; Script = "Modules/Scripts/DisableWPBT.ps1" }
    @{ Message = "Disabling Cortana"; Script = "Modules/Scripts/DisableCortana.ps1" }
    @{ Message = "Disabling Cloud Sync"; Script = "Modules/Scripts/DisableCloudSync.ps1" }
    @{ Message = "Disabling Windows Suggestions"; Script = "Modules/Scripts/DisableWindowsSuggestions.ps1" }
    @{ Message = "Tweaking Start Menu"; Script = "Modules/Scripts/TweakStartMenu.ps1" }
    @{ Message = "Tweaking Services"; Script = "Modules/Scripts/TweakServices.ps1" }
    @{ Message = "Uninstalling Bloatware"; Script = "Modules/Scripts/UninstallBloatware.ps1" }
    @{ Message = "Applying Optimized Powerplan"; Script = "Modules/Scripts/ApplyCustomPowerplan.ps1" }
)

function Optimize {
    param($config)
    

    foreach ($tweak in $tweaks) {
        $message = $tweak.Message
        $scriptPath = "/" + $tweak.Script

        Write-TrenLog $message
        $result = Run-TrenScript -Path $scriptPath -Config $config

        if (-not $result) {
            Write-TrenLog "Tweak failed: $message"
        }
    }

    Write-TrenLog "Optimization process completed!"
    1
}

return (Optimize -config $config)