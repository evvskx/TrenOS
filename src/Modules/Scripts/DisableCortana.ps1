function DisableCortana {
    try {
        if (Test-Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search') {
            Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search' -Name 'AllowCortana' -Value 0 -Type DWord
        }
    } catch {
        return 0
    }
    return 1
}

return (DisableCortana)