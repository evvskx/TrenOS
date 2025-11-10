# TrenOS - Loader
# @evvskx

$global:TrenOS = @{
    GithubRepoBaseUrl = "https://raw.githubusercontent.com/evvskx/TrenOS/refs/heads/main/src"
    Version = "v1.0.0-beta"
    Modules = @{}
}

function global:Write-TrenLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    $logDir = Join-Path $env:APPDATA "TrenOS\Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    $fileTimestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logFile = Join-Path $logDir "TrenOS_$(Get-Date -Format 'yyyy-MM-dd').log"
    
    $consoleTimestamp = "$([char]27)[32m- $([char]27)[33m$( (Get-Date).ToString('HH:mm:ss') )$([char]27)[36m ::$([char]27)[0m"
    
    $consoleMessage = "    $consoleTimestamp $Message"
    Write-Host $consoleMessage
    
    $logMessage = "$fileTimestamp $Message"
    try {
        Add-Content -Path $logFile -Value $logMessage -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

function Write-TrenLogo {
    Write-Host @"
        ,----,                                                       
      ,/   .`|                                 ,----..               
    ,`   .'  :                                /   /   \   .--.--.    
  ;    ;     /                               /   .     : /  /    '.  
.'___,/    ,'           __  ,-.      ,---,  .   /   ;.  \  :  /`. /  
|    :     |          ,' ,'/ /|  ,-+-. /  |.   ;   /  ` ;  |  |--`
;    |.';  ;   ,---.  '  | |' | ,--.'|'   |;   |  ; \ ; |  :  ;_     
`----'  |  |  /     \ |  |   ,'|   |  ,"' ||   :  | ; | '\  \    `.  
    '   :  ; /    /  |'  :  /  |   | /  | |.   |  ' ' ' : `----.   \ 
    |   :  |'   ;   /|;  : |   |   | |  |/  \   \  ',  / /  /`--'  / 
    '   :  |'   |  / ||  , ;   |   | |--'    ;   :    / '--'.     /  
    '---'   |   :    | ---'    |   |/         \   \ .'    `--'---'   
             \   \  /          '---'           `---`
              `----'                                                 
"@ -ForegroundColor Cyan
    Write-Host "`n"
}

function global:Run-TrenScript {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [object]$Config 
    )
    
    $isRemoteExecution = $MyInvocation.Line -like "*irm*" -or $MyInvocation.Line -like "*Invoke-WebRequest*"
    
    if ($isRemoteExecution) {
        $url = $TrenOS.GithubRepoBaseUrl + $Path
        try {
            $scriptContent = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
            $scriptBlock = [scriptblock]::Create($scriptContent)
            
            if ($Config) {  
                return & $scriptBlock -config $Config
            } else {
                return & $scriptBlock
            }
        }
        catch {
            Write-TrenLog "Failed to load from remote: $Path"
            Write-TrenLog "Error: $($_.Exception.Message)"
            return $null
        }
    }
    else {
        $localPaths = @()
        
        if ($PSScriptRoot) {
            $localPaths += Join-Path $PSScriptRoot $Path.TrimStart('/')
        }
        
        if ($PSCommandPath) {
            $scriptDir = Split-Path $PSCommandPath -Parent
            $localPaths += Join-Path $scriptDir $Path.TrimStart('/')
        }
        
        $localPaths += Join-Path (Get-Location).Path $Path.TrimStart('/')
        $localPaths += $Path
        
        $foundPath = $null
        foreach ($localPath in $localPaths) {
                if (Test-Path $localPath) {
                    $foundPath = $localPath
                    break
                }
            }

        
        if ($foundPath) {
            try {
                $scriptContent = Get-Content -Path $foundPath -Raw -ErrorAction Stop
                $scriptBlock = [scriptblock]::Create($scriptContent)
                
                if ($Config) {  
                    return & $scriptBlock -config $Config
                } else {
                    return & $scriptBlock
                }
            }
            catch {
                Write-TrenLog "Failed to load from local: $foundPath"
                Write-TrenLog "Error: $($_.Exception.Message)"
                return $null
            }
        }
        else {
            Write-TrenLog "Script not found: $Path"
            return $null
        }
    }
}

function Initialize-TrenOS {
    Write-TrenLogo
    
    $requirements = Run-TrenScript -Path "/Modules/VerifyRequirements.ps1"
    
    if ($requirements -eq $false) {
        Write-TrenLog "System requirements not met. TrenOS cannot continue."
        return $false
    }
    
    return $true
}

function Start-TrenOS {
    if (-not (Initialize-TrenOS)) {
        Write-TrenLog "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    $config = Run-TrenScript -Path "Modules\ConfigManager.ps1"
    
    if (-not $config) {
        Write-TrenLog "ConfigManager.ps1 did not return a valid configuration"
        return
    }
    
    $result = Run-TrenScript -Path "Modules\OptimizationManager.ps1" -Config $config

    if ($result) {
        Write-TrenLog "Optimization completed successfully"
    } else {
        Write-TrenLog "Optimization failed"
    }
}
if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '' -or $PSCommandPath) {
    Start-TrenOS
}