# TrenOS - Loader
# @evvskx

$global:TrenOS = @{
    GithubRepoBaseUrl = "https://raw.githubusercontent.com/evvskx/TrenOS/refs/heads/main/src"
    Version = "1.0.0"
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

function Run-TrenScript {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = @{}
    )
    
    $isRemoteExecution = $MyInvocation.Line -like "*irm*" -or $MyInvocation.Line -like "*Invoke-WebRequest*"
    
    if ($isRemoteExecution) {
        $url = $TrenOS.GithubRepoBaseUrl + $Path
        try {
            $scriptContent = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
            $scriptBlock = [scriptblock]::Create($scriptContent)
            
            if ($Parameters.Count -gt 0) {
                return & $scriptBlock @Parameters
            } else {
                return & $scriptBlock
            }
        }
        catch {
            Write-Error "$f Failed to load from remote: $Path"
            Write-Error "$f Error: $($_.Exception.Message)"
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
                
                if ($Parameters.Count -gt 0) {
                    return & $scriptBlock @Parameters
                } else {
                    return & $scriptBlock
                }
            }
            catch {
                Write-Error "$f Failed to load from local: $foundPath"
                Write-Error "$f Error: $($_.Exception.Message)"
                return $null
            }
        }
        else {
            $localPaths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            return $null
        }
    }
}

function Initialize-TrenOS {
    Write-TrenLogo
    
    $requirements = Run-TrenScript -Path "/Modules/VerifyRequirements.ps1"
    
    if ($requirements -eq $false) {
        Write-Error "System requirements not met. TrenOS cannot continue."
        return $false
    }
    
    return $true
}

function Start-TrenOS {
    if (-not (Initialize-TrenOS)) {
        Write-Host "Press any key to exit..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    $config = Run-TrenScript -Path "/Modules/Menu.ps1"
    # $optimization = Run-TrenScript -Path "/Modules/Optimizations.ps1"
}

if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '' -or $PSCommandPath) {
    Start-TrenOS
}