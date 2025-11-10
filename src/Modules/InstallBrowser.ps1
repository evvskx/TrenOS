function Install-Browser {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Browser
    )

    Run-TrenScript "/Modules/InstallChocolatey.ps1"

    $packages = @{
        "brave"   = "brave"
        "firefox" = "firefox"
        "edge"    = "microsoft-edge"
        "chrome"  = "googlechrome"
    }

    if (-not $packages.ContainsKey($Browser.ToLower())) {
        Write-TrenLog "Browser '$Browser' not supported"
        return
    }

    $packageName = $packages[$Browser.ToLower()]
    
    Write-TrenLog "Installing $Browser using Chocolatey..."
    
    try {
        & choco install $packageName -y --accept-license --no-progress
        
        if ($LASTEXITCODE -eq 0) {
            Write-TrenLog "$Browser installed successfully"
        } else {
            Write-TrenLog "Failed to install $Browser. Exit code: $LASTEXITCODE"
        }
    }
    catch {
        Write-TrenLog "Error installing $Browser : $($_.Exception.Message)"
    }

    return $true
}

return Install-Browser