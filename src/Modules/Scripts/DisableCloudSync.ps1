function DisableCloudSync {
    try {
        if (Test-Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\SyncSettings') {
            Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\SyncSettings' -Name 'SyncPolicy' -Value 0
        }
    } catch {
        return 0
    }
    return 1
}