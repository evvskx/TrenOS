function InstallDependencies {
    try {
        $ProgressPreference='SilentlyContinue'
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -ForceBootstrap -ErrorAction SilentlyContinue
        Write-TrenLog "NuGet package provider installed successfully"
    } catch {
        Write-TrenLog "Failed to install NuGet: $($_.Exception.Message)"
    }

    try {

        $timeouts = "--connect-timeout", "30", "--max-time", "300"

        $vcredists = [ordered] @{
            "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.exe"       = @("2005-x64", "/Q")
            "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.exe"       = @("2005-x86", "/Q")
            "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"       = @("2008-x64", "/Q")
            "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe"       = @("2008-x86", "/Q")
            "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"       = @("2010-x64", "/Q /NOREBOOT")
            "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"       = @("2010-x86", "/Q /NOREBOOT")
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" = @("2012-x64", "/install /quiet /norestart")
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" = @("2012-x86", "/install /quiet /norestart")
            "https://aka.ms/highdpimfc2013x64enu"                                                                       = @("2013-x64", "/install /quiet /norestart")
            "https://aka.ms/highdpimfc2013x86enu"                                                                       = @("2013-x86", "/install /quiet /norestart")
            "https://aka.ms/vs/17/release/vc_redist.x64.exe"                                                            = @("2015-2022-x64", "/install /quiet /norestart")
            "https://aka.ms/vs/17/release/vc_redist.x86.exe"                                                            = @("2015-2022-x86", "/install /quiet /norestart")
        }

        foreach ($a in $vcredists.GetEnumerator()) {
            $vcName = $a.Value[0]
            $vcArgs = $a.Value[1]
            $vcUrl = $a.Name
            $vcExePath = "$tempDir\vcredist-$vcName.exe"

            Write-TrenLog "Installing vcredist $vcName..."

            try {
                & curl.exe -LSs $vcUrl -o $vcExePath @timeouts

                if (Test-Path $vcExePath) {
                    
                    Start-Process -FilePath $vcExePath -ArgumentList $vcArgs -Wait -PassThru -WindowStyle Hidden
                    
                } else {
                    Write-TrenLog "Failed to download vcredist $vcName"
                }
            }
            catch {
                Write-TrenLog "Error installing vcredist $vcName : $($_.Exception.Message)"
            }
        }

        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    } catch {
        Write-TrenLog "Failed to install VC Redistributables: $($_.Exception.Message)"
        return 0
    }
    return 1
}

return (InstallDependencies)