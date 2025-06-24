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

# Copy the folder
Copy-Item -Path $TargetPath -Destination $destination -Recurse

# Remove the original folder
Remove-Item -Path $TargetPath -Recurse -Force

# Create a symlink
cmd /c mklink /D `"$TargetPath`" `"$destination`"

