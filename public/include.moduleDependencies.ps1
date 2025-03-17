# MODULE DEPENDENCIES - PUBLIC
#
# This script defines aliases and functions for module dependency management.
# It is intended to be included in public-facing scripts.

Set-MyInvokeCommandAlias -Alias "CloneRepo"              -Command 'git clone {url} {folder}'
Set-MyInvokeCommandAlias -Alias "TestGitHubRepo"         -Command 'Invoke-WebRequest -Uri "{url}" -Method Head -ErrorAction SilentlyContinue | ForEach-Object { $_.StatusCode -eq 200 }'
Set-MyInvokeCommandAlias -Alias "FindModule"             -Command 'Find-Module -Name {name} -AllowPrerelease -ErrorAction SilentlyContinue'
Set-MyInvokeCommandAlias -Alias "InstallModule"          -Command 'Install-Module -Name {name} -AllowPrerelease -Force'
Set-MyInvokeCommandAlias -Alias "GetModule"              -Command 'Get-Module -Name {name}'
Set-MyInvokeCommandAlias -Alias "GetModuleListAvailable" -Command 'Get-Module -Name {name} -ListAvailable'
Set-MyInvokeCommandAlias -Alias "ImportModule"           -Command 'Import-Module -Name {name} -Scope Global -Verbose:$false -PassThru'

# TODO: rename Invoke-GetMyModuleRootPath to something unique for your module
Set-MyInvokeCommandAlias -Alias "GetMyModuleRootPath"    -Command 'Invoke-GetMyModuleRootPath'
function Invoke-GetMyModuleRootPath{
[CmdletBinding()]
param()

# We will asume that this include file will be on a public,private or include folder.
$root = $PSScriptRoot | split-path -Parent

# confirm that in root folder we have a psd1 file
$psd1 = Get-ChildItem -Path $root -Filter *.psd1 -Recurse -ErrorAction SilentlyContinue

if(-Not $psd1){
    throw "Wrong root folder. Not PSD1 file found in [$root]. Modify Invoke-GetMyModuleRootPath to adjust location"
} 

return $root
} Export-ModuleMember -Function Invoke-GetMyModuleRootPath