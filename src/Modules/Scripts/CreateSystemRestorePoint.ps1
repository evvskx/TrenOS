function CreateSystemRestorePoint {
    foreach ($s in "VSS","srservice") {
        $svc=Get-Service $s -ErrorAction SilentlyContinue
        if ($svc) {
            if ($svc.StartType -eq "Disabled") {
                Set-Service $s -StartupType Manual
            }
            if ($svc.Status -ne "Running") {
                Start-Service $s
            }
        }
    }
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    & vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10GB | Out-Null
    New-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -PropertyType DWord -Force | Out-Null
    Checkpoint-Computer -Description ("OptiX " + (Get-Date -Format 'yyyy-MM-dd_HH-mm')) -RestorePointType "MODIFY_SETTINGS"
}

return (CreateSystemRestorePoint)