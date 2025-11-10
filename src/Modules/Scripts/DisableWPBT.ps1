function DisableWPBT {
    try {
        if (Test-Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\WPBT') {
            Set-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\WPBT' -Name 'DisableWPBT' -Value 1 -Type DWord
        }
    } catch {
        return 0
    }
    return 1
}

return (DisableWPBT)