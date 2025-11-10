function DisableVisualEffects {
    try {
        # Set appearance options to "custom"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -ErrorAction SilentlyContinue
        
        # Disable multiple visual effects through UserPreferencesMask
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -ErrorAction SilentlyContinue
        
        # Disable animate windows when minimizing and maximizing
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue
        
        # Disable taskbar animations
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -ErrorAction SilentlyContinue
        
        # Disable Aero Peek
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0 -ErrorAction SilentlyContinue
        
        # Disable taskbar thumbnail previews hibernation
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value 0 -ErrorAction SilentlyContinue
        
        # Show icons only instead of thumbnails
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 1 -ErrorAction SilentlyContinue
        
        # Disable translucent selection rectangle
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0 -ErrorAction SilentlyContinue
        
        # Disable show window contents while dragging
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value "0" -ErrorAction SilentlyContinue
        
        # Disable font smoothing
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "0" -ErrorAction SilentlyContinue
        
        # Disable drop shadows for icon labels
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0 -ErrorAction SilentlyContinue
   
        Set-ItemProperty -Path HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name EnableTransparency -Value 0
    } catch {
        return 0
    }

    return 1
}

return (DisableVisualEffects)