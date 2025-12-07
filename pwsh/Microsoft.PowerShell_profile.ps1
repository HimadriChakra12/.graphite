Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
# Utility Functions
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Editor Configuration
$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists pvim) { 'pvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists code) { 'code' }
          elseif (Test-CommandExists notepad++) { 'notepad++' }
          elseif (Test-CommandExists sublime_text) { 'sublime_text' }
          else { 'notepad' }
Set-Alias -Name v -Value $EDITOR

# Quick Access to Editing the Profile
function Edit-Profile {
    v $PROFILE
}
Set-Alias -Name ep -Value Edit-Profile

function touch($file) { "" | Out-File $file -Encoding ASCII }
function tv($file) { touch "$file" ; nvim "$file" }
# System Utilities
function admin {
    sudo pwsh
}

function dk($num){dx kill $num}
Function dl{dx list}
function br($url){
	start-process $url
}

function cmd{
    get-command |
        Select-Object Name |
        Format-Table -HideTableHeaders -AutoSize |
        fzf --preview "powershell -NoProfile -Command \"(Get-Command {}).Definition | Out-String | Write-Host\""
}
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin
function reload-profile {
    & $profile
}
function refresh-profile {
    . $profile
}
set-alias -name r -value refresh-Profile -Option AllScope -Scope Global -Force 
set-alias -name rr -value reload-profile -Option AllScope -Scope Global -Force 
function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
# Enhanced PowerShell Experience
# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode = 'Windows'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'  # SkyBlue (pastel)
        Parameter = '#98FB98'  # PaleGreen (pastel)
        Operator = '#FFB6C1'  # LightPink (pastel)
        Variable = '#DDA0DD'  # Plum (pastel)
        String = '#FFDAB9'  # PeachPuff (pastel)
        Number = '#B0E0E6'  # PowderBlue (pastel)
        Type = '#F0E68C'  # Khaki (pastel)
        Comment = '#D3D3D3'  # LightGray (pastel)
        Keyword = '#8367c7'  # Violet (pastel)
        Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
    }
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
}
Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
} else {
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force
Set-Alias -Name gg -Value lazygit -Option AllScope -Scope Global -Force
Set-alias -Name t -Value touch -Option AllScope -Scope Global -Force
#Set-Alias -Name ls -Value eza -Option AllScope -Scope Global -Force
Set-Alias -Name ls -Value lsx -Option AllScope -Scope Global -Force
Set-Alias -Name sudo -Value gsudo -Option AllScope -Scope Global -Force
Set-Alias -Name ll -Value Get-childitem -Option AllScope -Scope Global -Force
Set-Alias -Name qrk -Value quarkdown -Option AllScope -Scope Global -Force
function ..{
    cd ..
}
Function ...{
    .. && ..
}
function ....{
    ... && ..
}
function wtf?{
    $path = rg --files --no-filename | fzf --height 60% --layout reverse --border
    Start-Process $path
}
#"function list{get-childitem | select-object name | format-wide -Auto }"
function dirr {
  $items = Get-ChildItem | Select-Object -ExpandProperty Name
  $selected_item = $items | fzf --layout reverse --header "$pwd" --height 60% --preview="eza --color=always {} -T" 
  if ($selected_item){
    if (Test-Path -PathType Container $selected_item) {
    cd $selected_item
    zo
 }}}
set-alias -name dir -value dirr -Option AllScope -Scope Global -Force 
set-alias -name c -value clear -Option AllScope -Scope Global -Force 
set-alias -name cklear -value clear -Option AllScope -Scope Global -Force 
set-alias -name ckear -value clear -Option AllScope -Scope Global -Force 
#function lsd{$Directory = Get-ChildItem -Directory | Select-Object -expandproperty name  | fzf --height 30% --layout reverse --border && cd $Directory}
function zo {
  $items = @("..") + (Get-ChildItem | Select-Object -ExpandProperty Name)
  $selected_item = $items | fzf --layout reverse --header "$pwd" --height 90% --preview="eza --color=always {} -T"

  if ($selected_item) {
    if (Test-Path -PathType Container $selected_item) {
      cd $selected_item
      zo # Recursively call zo after changing directory
    } else {
      Start-Process -FilePath $selected_item
    }
  }
}
Set-Alias -Name f -Value zo -Option AllScope -Scope Global -Force
function exp{
    $location= Get-location
    explorer $location
}
Function yp{
    set-clipboard $pwd
}
function pin{
    "$pwd" | add-content ~/pindir.txt;
    nvim ~/pindir.txt -c "w"
}
function tui{taskkill /im explorer.exe /f}
function kill ($taskname){taskkill /im $taskname /f}
function pst { Get-Clipboard }
function cpy { Set-Clipboard $args[0] }
function zp { cd $(cat ~/pindir.txt | fzf)}
function gcl {
    param(
        [string]$n,
        [string]$u,
        [string]$s,
        [switch]$stars
    )

    $targetRoot = "$($pwd)"

    if ($stars) {
        $lines = gh api user/starred --paginate --jq '.[].full_name'
            if (-not $lines) {
                Write-Warning "You have no starred repositories."
                    return
            }

        $selected = $lines | fzf --prompt="⭐ Select a starred repo: "
            if (-not $selected) {
                Write-Warning "No repository selected."
                    return
            }

        $url = "https://github.com/$selected"
            Write-Host "Opening: $url"
            Start-Process $url
            return
    }

    if ($s){
        $json = gh search repos $s --json name,owner --limit 50
            if (-not $json) {
                Write-Warning "No results found."
                    return
            }

        $lines = ($json -split '},?{') | ForEach-Object {
            $owner = ($_ -match '"login":\s*"([^"]+)"') ? $matches[1] : ''
                $n = ($_ -match '"name":\s*"([^"]+)"') ? $matches[1] : ''
                if ($owner -and $n) { "$owner/$n" }
        }

        if (-not $lines) {
            Write-Warning "No repositories matched."
                return
        }

        $selected = $lines | fzf --prompt="Select repo: "
            $sel = "https://github.com/$($selected)"
            if ($selected) {
                if (-not $n) {
                    $n = ($url -split '/')[-1] -replace '\.git$', ''
                }
                git clone "$sel" "$targetRoot/$n"
            } else {
                Write-Warning "No repository selected."
            }
    }

    if ($u) {
        if (-not $n) {
            $n = ($u -split '/')[-1] -replace '\.git$', ''
        }
        git clone "$u" "$targetRoot/$n"
        Set-Location "$targetRoot/$n"
        return
    }
    
    # Interactive mode using gh and fzf
    $repo = gh repo list HimadriChakra12 --limit 100 --json name --jq '.[].name' | fzf

    if (-not $repo) {
        Write-Host "No repository selected."
        return
    }

    $cloneUrl = "https://github.com/HimadriChakra12/$repo"
    git clone $cloneUrl "$targetRoot/$repo"
    Set-Location "$targetRoot/$repo"
}
function q{exit}
function env {
    param(
            [string]$NewPath
         )

        if (-not $NewPath) {
            Write-Host "Usage: .\AddToPath.ps1 -NewPath <folder_path>"
                exit 1
        }

# Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if path already exists (case-insensitive)
        if ($currentPath.Split(';') -contains $NewPath) {
            Write-Host "Path already exists in the user PATH variable."
        } else {
# Append new path
            $newPathValue = $currentPath + ";" + $NewPath
                [Environment]::SetEnvironmentVariable("Path", $newPathValue, "User")
                Write-Host "Path added to user PATH variable. You may need to restart your session for changes to take effect."
        }
}
function gs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$query
    )

    $json = gh search repos $query --json name,owner --limit 50
    if (-not $json) {
        Write-Warning "No results found."
        return
    }

    $repos = ($json | ConvertFrom-Json) | ForEach-Object {
        "$($_.owner.login)/$($_.name)"
    }

    if (-not $repos) {
        Write-Warning "No repositories matched."
        return
    }

    $selected = $repos | fzf --prompt="Select repo: " --preview='gh repo view {} ' --preview-window=right:70%

    if ($selected) {
        $url = "https://github.com/$selected"
        $url | Set-Clipboard
        Write-Host "Copied: $url"
    } else {
        Write-Warning "No repository selected."
    }
}


function walls{
$wall = Get-ChildItem -Path "$HOME\.graphite\wallpaper" -Recurse |
    Select-Object -ExpandProperty FullName | fzf 
    $wall | set-clipboard
}

function lazyreset{
    $path = "~/appdata/local/lazygit"
        if (test-path $Path){
            rm $path -r -force
        }
}
function wrq($url){
    iwr -useb "$url" | iex
}

