param (
    [string]$TargetPath
)

$graphiteRoot = "$env:USERPROFILE\.graphite"
$folderName = Split-Path -Path $TargetPath -Leaf
$destination = Join-Path $graphiteRoot $folderName

# Ensure graphite folder exists
if (!(Test-Path $graphiteRoot)) {
    New-Item -Path $graphiteRoot -ItemType Directory | Out-Null
}

# If folder already exists in graphite
if (Test-Path $destination) {
    Write-Host "Folder already exists in graphite. Skipping copy."
} else {
    # Copy folder to graphite
    Copy-Item -Path $TargetPath -Destination $destination -Recurse
}

# Remove the original folder
Remove-Item -Path $TargetPath -Recurse -Force

# Create symbolic link
cmd /c mklink /D `"$TargetPath`" `"$destination`"
