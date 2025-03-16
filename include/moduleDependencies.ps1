# MODULE DEPENDENCIES
#
# Module dependency management script
#
# This script provides functionality to manage module dependencies.
# It includes functions to import modules from various sources such as:
# - PowerShell Module Manager
# - Side-by-side paths
# - Public GitHub repositories
#
# Usage:
# Call `Import-Dependency -Name <ModuleName>` with the module name to import it from the appropriate source.
#
# TODO: Create a related public ps1
# 1. Define aliases for commands like "CloneRepo" and "TestGitHubRepo".
# 2. Include these definitions in a separate file, possibly named `include.dependency.ps1`, in the public folder.
# 3. Include function to it too
#
# Sample code:
#   Set-MyInvokeCommandAlias -Alias "CloneRepo" -Command 'git clone {url} {folder}'
#   Set-MyInvokeCommandAlias -Alias "TestGitHubRepo" -Command 'Invoke-WebRequest -Uri "{url}" -Method Head -ErrorAction SilentlyContinue | ForEach-Object { $_.StatusCode -eq 200 }'
#   Set-MyInvokeCommandAlias -Alias "GetMyModuleRootPath" -Command 'Invoke-GetMyModuleRootPath'

#   
#  function Invoke-GetMyModuleRootPath{
#     [CmdletBinding()]
#     param()

#     # We will asume that this include file will be on a public,private or include folder.
#     $root = $PSScriptRoot | split-path -Parent

#     # confirm that in root folder we have a psd1 file
#     $psd1 = Get-ChildItem -Path $root -Filter *.psd1 -Recurse -ErrorAction SilentlyContinue

#     if(-Not $psd1){
#         throw "Wrong root folder. Not PSD1 file found in [$root]. Modify Invoke-GetMyModuleRootPath to adjust location"
#     } 
    
#     return $root
# } Export-ModuleMember -Function Invoke-GetMyModuleRootPath

function Import-Dependency{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Name
    )

    process {
        #1. Check if the module is already imported and reloads it from it's own module

        $module = Get-Module -Name $Name
        if ($module) {
            $module = Import-MyModule -Name $module.Path
            if($module){
                "Module [$Name] imported from own module" | Write-Verbose
                return $module
            } else {
                "Failed to reload module [$Name] from own module" | Write-Verbose
            }
        }

        #3. import from side by side path
        $meModuleRootPath = Invoke-MyCommand -Command 'GetMyModuleRootPath'
        $modulePath = $meModuleRootPath | split-path -Parent | Join-Path -ChildPath $Name

        if(Test-Path -Path $modulePath){
            $module = Import-MyModule -Name $modulePath
            if($module){
                "Module [$Name] imported from side by side path" | Write-Verbose
                return $module
            } else {
                "Failed to reaload module [$Name] from side by side path" | Write-Verbose
                "Fix or demo side by side path module for [$Name] and try again" | Write-Errror
                return $null
            }
        }

        #2. imports from powerselll module manger
        $moduleAvailable = Get-Module -Name $Name -ListAvailable
        if ($moduleAvailable) {
            $module = Import-MyModule -Name $moduleAvailable.Path
            if($module){
                "Module [$Name] imported from Powershell Module Manager" | Write-Verbose
                return $module
            } else {
                "Failed to reaload module [$Name] from Powershell Module Manager" | Write-Verbose
            }
        }

        #4. clones from public GitHub Repository, side by side, and imports it
        #  1. Default module path is https://github.com/rulasg/moduleName
        #  2. If the module is not found, it will be cloned from the GitHub repository

        $url = "https://github.com/{owner}/{name}"
        $testUrl = Invoke-MyCommand -Command 'TestGitHubRepo' -Parameters @{ url = $url } -ErrorAction SilentlyContinue
        
        if ($testUrl -eq $true) {
            $modulePath = $PSScriptRoot | split-path -Parent | Join-Path -ChildPath $Name

            $null = Invoke-MyCommand -Command 'CloneRepo' -Parameters @{ url = $url; folder = $modulePath }

            # check if result is success
            if(Test-Path -Path $modulePath){
                "Module [$Name] cloned from GitHub repository" | Write-Verbose
            } else {
                "Failed to clone the module from [$url]" | Write-Verbose
                return $false
            }

            $module = Import-MyModule -Name $modulePath
            if($module){
                "Module [$Name] imported from GitHub repository" | Write-Verbose
                return $module
            } else {
                "Failed to reload module [$Name] from GitHub repository" | Write-Verbose
                return $null
            }
        } 
        else # Url not found
        {
            "Module [$Name] not found in GitHub repository" | Write-Verbose
            return $null
        }
    }
} Export-ModuleMember -Function Import-Dependency

function Import-MyModule{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Name
    )

    process {
        $module = Import-Module -Name $Name -Scope Global -Verbose:$false -PassThru

        $result = Get-Module -Name $module.Name
        
        return $result

    }
} Export-ModuleMember -Function Import-MyModule
