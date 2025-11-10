function Get-DefaultBrowser {
    try {
        $userChoicePath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        if (Test-Path $userChoicePath) {
            $progId = (Get-ItemProperty -Path $userChoicePath -Name "ProgId" -ErrorAction SilentlyContinue).ProgId
            if ($progId) {
                $browserMap = @{
                    "ChromeHTML" = "Chrome"
                    "FirefoxURL" = "Firefox"
                    "BraveHTML" = "Brave"
                    "MSEdgeHTM" = "Edge"
                    "MSEdgeHTMA" = "Edge"
                    "IE.HTTP" = "Internet Explorer"
                    "OperaStable" = "Opera"
                    "Vivaldi" = "Vivaldi"
                    "SafariHTML" = "Safari"
                    "ZenHTML" = "Zen"
                    "ThoriumHTML" = "Thorium"
                    "WaterfoxHTML" = "Waterfox"
                    "LibreWolfHTML" = "LibreWolf"
                    "FloorpHTML" = "Floorp"
                    "EpicHTML" = "Epic"
                    "MaxthonHTML" = "Maxthon"
                    "CentBrowserHTML" = "CentBrowser"
                    "CocCocHTML" = "CocCoc"
                    "SlimBrowserHTML" = "SlimBrowser"
                    "PaleMoonHTML" = "PaleMoon"
                    "K-MeleonHTML" = "K-Meleon"
                    "SRWareIronHTML" = "SRWare Iron"
                    "ComodoDragonHTML" = "Comodo Dragon"
                    "AvastSafeZoneHTML" = "Avast Secure Browser"
                    "AVGSafeBrowserHTML" = "AVG Secure Browser"
                    "YandexHTML" = "Yandex"
                }
                
                if ($browserMap.ContainsKey($progId)) {
                    $browserName = $browserMap[$progId]
                    return $browserName
                } else {
                }
            }
        }
        
        $httpProgId = (Get-ItemProperty "HKCU:\Software\Classes\.html" -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
        if ($httpProgId) {
            $browserCommand = (Get-ItemProperty "HKCU:\Software\Classes\$httpProgId\shell\open\command" -Name "(default)" -ErrorAction SilentlyContinue)."(default)"
            if ($browserCommand) {
                $cleanPath = $browserCommand -replace '"([^"]+)".*', '$1'
                $fileName = [System.IO.Path]::GetFileNameWithoutExtension($cleanPath)
                
                $fileMap = @{
                    "chrome" = "Chrome"
                    "firefox" = "Firefox"
                    "brave" = "Brave"
                    "msedge" = "Edge"
                    "iexplore" = "Internet Explorer"
                    "opera" = "Opera"
                    "vivaldi" = "Vivaldi"
                    "safari" = "Safari"
                    "zen" = "Zen"
                    "thorium" = "Thorium"
                    "waterfox" = "Waterfox"
                    "librewolf" = "LibreWolf"
                    "floorp" = "Floorp"
                    "epic" = "Epic"
                    "maxthon" = "Maxthon"
                    "centbrowser" = "CentBrowser"
                    "coccoc" = "CocCoc"
                    "slimbrowser" = "SlimBrowser"
                    "palemoon" = "PaleMoon"
                    "k-meleon" = "K-Meleon"
                    "iron" = "SRWare Iron"
                    "dragon" = "Comodo Dragon"
                    "avast" = "Avast Secure Browser"
                    "avg" = "AVG Secure Browser"
                    "yandex" = "Yandex"
                }
                
                if ($fileMap.ContainsKey($fileName.ToLower())) {
                    $browserName = $fileMap[$fileName.ToLower()]
                    return $browserName
                } else {
                    return $fileName
                }
            }
        }
        
        return "Unknown"
    }
    catch {
        return "Unknown"
    }
}

return Get-DefaultBrowser
