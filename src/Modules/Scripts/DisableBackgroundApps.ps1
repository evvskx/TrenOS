function DisableBackgroundApps {
    try {
        New-Item -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications' -Force | Out-Null
        Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Value 1 -Type DWord
    } catch {
        return 0
    }
    
    return 1
}

return (DisableBackgroundApps)