function DisableWindowsSuggestions {
    try {
        Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager' -Name 'SystemPaneSuggestionsEnabled' -Value 0
    } catch {
        return 0
    }
    return 1
}

return (DisableWindowsSuggestions)