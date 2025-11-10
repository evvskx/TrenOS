
$tweaks = @(
    @("Disabling Telemetry", "Modules\Scripts\DisableTelemetry.ps1")
)

function Optimize {
    param($config)
    
    Write-TrenLog "Starting optimization process..."
    
    foreach ($tweak in $tweaks) {
        $message = $tweak[0]
        $scriptPath = Join-Path (Split-Path -Parent $Script:PSCommandPath) $tweak[1]
        
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
