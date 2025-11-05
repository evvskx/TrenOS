# TrenOS - Loader
# @evvskx

$global:TrenOS = @{
    GithubRepoBaseUrl = "https://raw.githubusercontent.com/evvskx/TrenOS/refs/heads/main{0}"
    Version = "1.0.0"
    Modules = @{}
}

$global:time = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffzzz")

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
    
    $url = $TrenOS.GithubRepoBaseUrl -f $Path
    try {
        Write-Host "[$time] Loading: $Path" -ForegroundColor Cyan
        
        $scriptBlock = [scriptblock]::Create((Invoke-WebRequest -Uri $url -UseBasicParsing).Content)
        
        if ($Parameters.Count -gt 0) {
            return & $scriptBlock @Parameters
        } else {
            return & $scriptBlock
        }
    }
    catch {
        Write-Error "[$time] Failed to load: $Path"
        Write-Error "[$time] Error: $($_.Exception.Message)"
        return $null
    }
}

function Initialize-TrenOS {
    Write-TrenLogo
    Write-Host "Initializing TrenOS..." -ForegroundColor Green
    
    $requirements = Run-TrenScript -Path "/src/Modules/VerifyRequirements.ps1"
    
    if ($requirements -eq $false) {
        Write-Error "System requirements not met. TrenOS cannot continue."
        return $false
    }
    
    Write-Host "TrenOS initialized successfully!" -ForegroundColor Green
    return $true
}

function Start-TrenOS {
    if (-not (Initialize-TrenOS)) {
        Write-Host "Press any key to exit..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
}

if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
    Start-TrenOS
}