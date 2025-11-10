function UninstallBloatware {
    try {
        $appsToRemove = @(
            "Microsoft.Microsoft3DViewer",
            "Microsoft.AppConnector",
            "Microsoft.BingFinance",
            "Microsoft.BingNews", 
            "Microsoft.BingSports",
            "Microsoft.BingTranslator",
            "Microsoft.BingWeather",
            "Microsoft.BingFoodAndDrink",
            "Microsoft.BingHealthAndFitness",
            "Microsoft.BingTravel",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.Messaging",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.NetworkSpeedTest",
            "Microsoft.News",
            "Microsoft.Office.Lens",
            "Microsoft.Office.Sway",
            "Microsoft.Office.OneNote",
            "Microsoft.OneConnect",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "Microsoft.Wallet",
            "Microsoft.Whiteboard",
            "Microsoft.WindowsAlarms",
            "microsoft.windowscommunicationsapps",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.ConnectivityStore",
            "Microsoft.ScreenSketch",
            "Microsoft.MixedReality.Portal",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo",
            "Microsoft.MicrosoftOfficeHub",
            
            "*EclipseManager*",
            "*ActiproSoftwareLLC*",
            "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
            "*Duolingo-LearnLanguagesforFree*",
            "*PandoraMediaInc*",
            "*CandyCrush*",
            "*BubbleWitch3Saga*",
            "*Wunderlist*",
            "*Flipboard*",
            "*Twitter*",
            "*Facebook*",
            "*Royal Revolt*",
            "*Sway*",
            "*Speed Test*",
            "*Dolby*",
            "*Viber*",
            "*ACGMediaPlayer*",
            "*OneCalendar*",
            "*LinkedInforWindows*",
            "*HiddenCityMysteryofShadows*",
            "*HiddenCity*",
            "*AdobePhotoshopExpress*",
            "*HotspotShieldFreeVPN*",
            "Microsoft.Advertising.Xaml"
        )

        $preservedApps = @(
            "*Microsoft.WindowsStore*",              
            "*Microsoft.DesktopAppInstaller*",       
            "*Microsoft.StorePurchaseApp*",          
            "*Microsoft.Services.Store.Engagement*",
            "*Microsoft.UI.Xaml*",                   
            "*Microsoft.VCLibs*",                    
            "*Microsoft.NET.Native*",                
            "*Microsoft.GamingServices*",            
            "*Microsoft.MinecraftUWP*",              
            "*Netflix*",                             
            "*Microsoft.Xbox*"                       
        )

        foreach ($appPattern in $appsToRemove) {
            $apps = Get-AppxPackage -AllUsers | Where-Object { 
                $_.Name -like $appPattern -and 
                -not ($preservedApps | Where-Object { $_.Name -like $_ })
            }
            
            if ($apps) {
                $apps | Remove-AppxPackage -ErrorAction SilentlyContinue
            }

            $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { 
                $_.PackageName -like $appPattern -and 
                -not ($preservedApps | Where-Object { $_.PackageName -like $_ })
            }
            
            if ($provisioned) {
                $provisioned | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            }
        }

        
    } catch {
        return 0
    }
    return 1
}