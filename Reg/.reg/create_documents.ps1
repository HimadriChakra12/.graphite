param([string]$folderPath)

$today = Get-Date -Format "yyyy-MM-dd"
$newFolder = Join-Path -Path $folderPath -ChildPath "Documents $today"

if (-Not (Test-Path $newFolder)) {
    New-Item -ItemType Directory -Path $newFolder | Out-Null
}
