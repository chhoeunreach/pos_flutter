$ErrorActionPreference = 'Stop'

$appName = 'POS App'
$publisher = 'POS App'
$installRoot = Join-Path $env:LOCALAPPDATA 'Programs\POS App'
$zipPath = Join-Path $PSScriptRoot 'pos_app_windows_release.zip'
$exePath = Join-Path $installRoot 'pos_app.exe'

if (Test-Path $installRoot) {
    Remove-Item -LiteralPath $installRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
Expand-Archive -LiteralPath $zipPath -DestinationPath $installRoot -Force

$shell = New-Object -ComObject WScript.Shell
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) "$appName.lnk"
$startMenuDir = Join-Path ([Environment]::GetFolderPath('Programs')) $publisher
$startMenuShortcut = Join-Path $startMenuDir "$appName.lnk"
New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null

foreach ($shortcutPath in @($desktopShortcut, $startMenuShortcut)) {
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = $installRoot
    $shortcut.IconLocation = "$exePath,0"
    $shortcut.Save()
}

Start-Process -FilePath $exePath -WorkingDirectory $installRoot
