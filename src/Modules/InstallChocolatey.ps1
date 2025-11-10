function Install-Chocolatey {
    Write-TrenLog "Installing chocolatey..."

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            Write-TrenLog "ERROR: $($_.Exception.Message)"
        }
    }
}

return Install-Chocolatey