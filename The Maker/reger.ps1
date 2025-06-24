$menuName = "Make Graphite"
$scriptPath = "$env:USERPROFILE\.graphite\The Maker\maker.ps1"

New-Item -Path "HKCU:\Software\Classes\Directory\shell\$menuName" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\$menuName" -Name "Icon" -Value "powershell.exe" | Out-Null
New-Item -Path "HKCU:\Software\Classes\Directory\shell\$menuName\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\$menuName\command" -Name "(default)" -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" `"%1`""

