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
    |   |  '.    ' / ||  | '   |   | |  | |'   ;  \; /  | __ \  \  | 
    '   :  |'   ;   /|;  : |   |   | |  |/  \   \  ',  / /  /`--'  / 
    ;   |.' '   |  / ||  , ;   |   | |--'    ;   :    / '--'.     /  
    '---'   |   :    | ---'    |   |/         \   \ .'    `--'---'   
             \   \  /          '---'           `---`                 
              `----'                                                 
"@ -ForegroundColor Cyan
    Write-Host "           Get your PC on Steroids!" -ForegroundColor Yellow
    Write-Host "                  Version $($TrenOS.Version)" -ForegroundColor Gray
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
        
        # Download e esecuzione dello script
        $scriptBlock = [scriptblock]::Create((Invoke-WebRequest -Uri $url -UseBasicParsing).Content)
        
        # Passa i parametri allo script se presenti
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
    
    # Verifica requisiti di base
    $requirements = Run-TrenScript -Path "/Modules/VerifyRequirements.ps1"
    
    if ($requirements -eq $false) {
        Write-Error "System requirements not met. TrenOS cannot continue."
        return $false
    }
    
    Write-Host "TrenOS initialized successfully!" -ForegroundColor Green
    return $true
}

function Show-TrenMenu {
    Clear-Host
    Write-TrenLogo
    
    Write-Host "=== TRENOS MAIN MENU ===" -ForegroundColor Green
    Write-Host "1. System Requirements Check" -ForegroundColor White
    Write-Host "2. Install Packages" -ForegroundColor White
    Write-Host "3. System Configuration" -ForegroundColor White
    Write-Host "4. Utilities" -ForegroundColor White
    Write-Host "5. Update TrenOS" -ForegroundColor White
    Write-Host "6. Exit" -ForegroundColor White
    Write-Host "`n"
}

function Invoke-TrenMenu {
    param([string]$Choice)
    
    switch ($Choice) {
        "1" { 
            Write-Host "`nRunning System Requirements Check..." -ForegroundColor Yellow
            Run-TrenScript -Path "/Modules/VerifyRequirements.ps1"
        }
        "2" { 
            Write-Host "`nLoading Package Installer..." -ForegroundColor Yellow
            Run-TrenScript -Path "/Modules/InstallPackages.ps1"
        }
        "3" { 
            Write-Host "`nLoading System Configuration..." -ForegroundColor Yellow
            Run-TrenScript -Path "/Modules/SystemConfig.ps1"
        }
        "4" { 
            Write-Host "`nLoading Utilities..." -ForegroundColor Yellow
            Run-TrenScript -Path "/Modules/Utilities.ps1"
        }
        "5" { 
            Write-Host "`nChecking for Updates..." -ForegroundColor Yellow
            Run-TrenScript -Path "/Modules/UpdateTrenOS.ps1"
        }
        "6" { 
            Write-Host "Arrivederci!" -ForegroundColor Green
            return $false
        }
        default { 
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
        }
    }
    
    return $true
}

function Start-TrenOS {
    # Inizializza TrenOS
    if (-not (Initialize-TrenOS)) {
        Write-Host "Press any key to exit..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }
    
    # Loop principale del menu
    do {
        Show-TrenMenu
        $choice = Read-Host "Select an option (1-6)"
        $continue = Invoke-TrenMenu -Choice $choice
        
        if ($continue -and $choice -ne "6") {
            Write-Host "`nPress any key to continue..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($continue)
}

# Export delle funzioni pubbliche
Export-ModuleMember -Function Run-TrenScript, Start-TrenOS

# Avvio automatico se eseguito direttamente
if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
    Start-TrenOS
}