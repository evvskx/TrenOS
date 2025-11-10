#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#                               Menu                              #
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

function Get-UserChoice {
    param(
        [string]$Question,
        [string[]]$Options,
        [int]$DefaultChoice = 1
    )
    
    Write-TrenLog "$Question"
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-TrenLog "$($i+1). $($Options[$i])"
    }
    
    Write-Host "    $([char]27)[32m- $([char]27)[33m$( (Get-Date).ToString('HH:mm:ss') )$([char]27)[36m ::$([char]27)[0m Select option (1-$($Options.Count)): " -NoNewline
    $choice = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($choice) -and $DefaultChoice) {
        return $DefaultChoice
    }
    
    while ($choice -notin 1..$Options.Count) {
        Write-Host "    $([char]27)[32m- $([char]27)[33m$( (Get-Date).ToString('HH:mm:ss') )$([char]27)[36m ::$([char]27)[0m Invalid choice. Please enter 1-$($Options.Count): " -NoNewline
        $choice = Read-Host
        $choice = $choice.Trim()
    }

    return [int]$choice
}

function Get-YesNoChoice {
    param(
        [string]$Question,
        [bool]$DefaultChoice = $true
    )
    
    $defaultText = if ($DefaultChoice) { "Y/n" } else { "y/N" }
    
    Write-Host "    $([char]27)[32m- $([char]27)[33m$( (Get-Date).ToString('HH:mm:ss') )$([char]27)[36m ::$([char]27)[0m $Question [$defaultText] " -NoNewline
    $choice = Read-Host
    
    $userChoice = if ([string]::IsNullOrWhiteSpace($choice)) { 
        if ($DefaultChoice) { "Y" } else { "N" }
    } else { 
        $choice 
    }
    
    if ([string]::IsNullOrWhiteSpace($choice)) {
        return $DefaultChoice
    }
    
    $choice = $choice.ToLower()
    while ($choice -notin @('y', 'n', 'yes', 'no')) {
        Write-Host "    $([char]27)[32m- $([char]27)[33m$( (Get-Date).ToString('HH:mm:ss') )$([char]27)[36m ::$([char]27)[0m Invalid choice. Please enter Y or N: " -NoNewline
        $choice = Read-Host
        $choice = $choice.ToLower()
    }
    
    $result = $choice -in @('y', 'yes')
    return $result
}

function Show-Menu {
    Write-TrenLog "Welcome to TrenOS!"
    Write-TrenLog "Please answer the following questions to customize your setup:"
    
    $config = @{}
    
    $defaultBrowser = Run-TrenScript -Path "/Modules/FetchBrowser.ps1"
    $useDefaultBrowser = Get-YesNoChoice -Question "Do you wanna use ${defaultBrowser} as default browser?" -DefaultChoice $true
    
    if (-not $useDefaultBrowser) {
        Write-TrenLog "Which browser you wanna use:"
        $browserChoice = Get-UserChoice -Question "Select your preferred browser:" -Options @("Brave", "Firefox", "Edge", "Chrome") -DefaultChoice 1
        $config.Browser = @("Brave", "Firefox", "Edge", "Chrome")[$browserChoice - 1]
    } else {
        $config.Browser = $defaultBrowser
        Write-TrenLog "Using default browser: $($config.Browser)"
    }
    
    $config.DisableDefender = Get-YesNoChoice -Question "Disable Windows Defender?" -DefaultChoice $false
    Write-TrenLog "Configuration completed. Summary:"
    
    foreach ($key in $config.Keys) {
        $value = if ($config[$key] -is [bool]) { 
            if ($config[$key]) { "YES" } else { "NO" } 
        } else { 
            $config[$key] 
        }
        Write-TrenLog "  $key : $value"
    }

    $proceed = Get-YesNoChoice -Question "Proceed with these settings?" -DefaultChoice $true
    
    if ($proceed) {
        return $config
    } else {
        Write-TrenLog "Configuration cancelled by user."
        return $null
    }
}

return Show-Menu