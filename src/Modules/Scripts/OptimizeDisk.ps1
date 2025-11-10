function OptimizeDisk {
    try {
        Start-Process -WindowStyle Hidden -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1"
        Start-Process -WindowStyle Hidden -FilePath "defrag.exe" -ArgumentList "C: /O" -Wait
    } catch {
        return 0
    }
    return 1
}

return (OptimizeDisk)