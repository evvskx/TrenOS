function ApplyCustomPowerplan {
    try {
        $path="$env:TEMP\\plan.pow"
        & curl.exe -LSs "https://raw.githubusercontent.com/evvskx/TrenOS/refs/heads/main/Assets/Powerplan/BOHRV2.pow" -o "$path"
        $guid=(powercfg -import $path | ForEach-Object { ($_ -match 'GUID:\\s+([a-f0-9-]+)') | Out-Null; $matches[1] })
        powercfg -setactive $guid
    } catch {
        return 0
    }
    return 1
}