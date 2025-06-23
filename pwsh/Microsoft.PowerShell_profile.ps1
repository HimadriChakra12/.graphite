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
# System Utilities
function admin {
    sudo pwsh
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
Set-Alias -Name su -Value admin
function reload-profile {
    & $profile
}
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
Set-Alias -Name ls -Value eza -Option AllScope -Scope Global -Force
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
#function lsd{$Directory = Get-ChildItem -Directory | Select-Object -expandproperty name  | fzf --height 30% --layout reverse --border && cd $Directory}
function zo {
  $items = @("..") + (Get-ChildItem | Select-Object -ExpandProperty Name)
  $selected_item = $items | fzf --layout reverse --header "$pwd" --height 90% --preview="eza --color=always {} -T"

  if ($selected_item) {
    if (Test-Path -PathType Container $selected_item) {
      cd $selected_item
      Write-Host "($pwd)" -ForegroundColor Yellow
      zo # Recursively call zo after changing directory
    } else {
      Start-Process -FilePath $selected_item
    }
  }
}
function exp{
    $location= Get-location
    explorer $location
}
Function yp{
    set-clipboard $pwd
}
