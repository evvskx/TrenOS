function DisableActivityHistory {
    try {
        if (Test-Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Diagnostics\\ActivityFeed\\Publishers') {
            Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Diagnostics\\ActivityFeed\\Publishers' -Name 'UserEnabled' -Value 0
        }
    } catch {
        return 0
    }
    return 1
}

return (DisableActivityHistory)