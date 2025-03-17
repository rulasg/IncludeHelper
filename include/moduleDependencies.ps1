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
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Name
    )

    process {
        #1. Check if the module is already imported and reloads it from it's own module

        $module = Invoke-MyCommand -Command 'GetModule' -Parameters @{ name = $Name }
        if ($module) {
            $module = Import-MyModule -Name $module.Path
            if($module){
                "Module [$Name] imported from own module" | Write-Verbose
                return $module
            } else {
                "Failed to reload module [$Name] from own module" | Write-Verbose
            }
        }

        #2. import from side by side path
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

        #3. imports from powerselll module manger
        $moduleAvailable = Invoke-MyCommand -Command 'GetModuleListAvailable' -Parameters @{ name = $Name }
        if ($moduleAvailable) {
            $module = Import-MyModule -Name $moduleAvailable.Path
            if($module){
                "Module [$Name] imported from Powershell Module Manager" | Write-Verbose
                return $module
            } else {
                "Failed to reaload module [$Name] from Powershell Module Manager" | Write-Verbose
            }
        }

        # 4. Install the module from PowerShell Gallery
        $module = Invoke-MyCommand -Command 'GetModuleListAvailable' -Parameters @{ name = $Name }
        if(-Not $module){
            # find moduule in PowerShell Gallery
            $moduleAvailable = Invoke-MyCommand -Command 'FindModule' -Parameters @{ name = $Name}
            if ($moduleAvailable) {
                # this does not return any module
                if ($PSCmdlet.ShouldProcess("Installing module $name", "Do you want to install [$Name] from PowerShell Gallery?")) {
                    Invoke-MyCommand -Command 'InstallModule' -Parameters @{ name = $Name }
                    #Check if the module is available now
                    $module = Invoke-MyCommand -Command 'GetModuleListAvailable' -Parameters @{ name = $Name }
                    if($module){
                        "Module [$Name] installed from PowerShell Gallery" | Write-Verbose
                        return $module
                    } else {
                        "Failed to install module [$Name] from PowerShell Gallery" | Write-Verbose
                    }
                } else {
                    "Module [$Name] not imported. Skipped installed from PowerShell Gallery" | Write-Warning
                    return $null
                }
            }
        }

        #5. clones from public GitHub Repository, side by side, and imports it
        #  1. Default module path is https://github.com/rulasg/moduleName
        #  2. If the module is not found, it will be cloned from the GitHub repository

        $url = "https://github.com/rulasg/$name"
        $testUrl = Invoke-MyCommand -Command 'TestGitHubRepo' -Parameters @{ url = $url } -ErrorAction SilentlyContinue
        
        if ($testUrl -eq $true) {
            # Clone side by side this module
            $local = Invoke-MyCommand -Command 'GetMyModuleRootPath'
            $modulePath = $local | split-path -Parent | Join-Path -ChildPath $Name

            if ($PSCmdlet.ShouldProcess("Cloning module $name", "Do you want to cline [$url] to [$modulePath]?")) {
                $null = Invoke-MyCommand -Command 'CloneRepo' -Parameters @{ url = $url; folder = $modulePath }
            } else {
                "Module [$Name] not cloned. Skipped clone from GitHub repository" | Write-Warning
                return $null
            }

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
        # $module = Import-Module -Name $Name -Scope Global -Verbose:$false -PassThru
        $module = Invoke-MyCommand -Command 'ImportModule' -Parameters @{ name = $Name}

        # $result = Get-Module -Name $module.Name
        $result = Invoke-MyCommand -Command 'GetModule' -Parameters @{ name = $module.Name }
        
        return $result

    }
}

function Confirm-ActionExample {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)][string]$ActionName
    )

    process {
        if ($PSCmdlet.ShouldProcess("Performing action: $ActionName", "Do you want to proceed?")) {
            Write-Host "Action [$ActionName] confirmed and executed."
            # ...perform the action here...
        } else {
            Write-Warning "Action [$ActionName] was not confirmed. Skipping execution."
        }
    }
}