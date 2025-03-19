# CONFIG - PUBLIC
#
# This script defines aliases and functions for configuration management specific to "MyModule".
# It is intended to be included in public-facing scripts.

# Define unique aliases for "MyModule"
$CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "MyModuleGetConfigRootPath"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-MyModuleGetConfigRootPath"

# Set the alias for the root path command
Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD

# Define the function to get the configuration root path
function Invoke-MyModuleGetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = GetConfigRootPath
    return $configRoot
}

Export-ModuleMember -Function Invoke-MyModuleGetConfigRootPath

# Extra functions not needed by INCLUDE CONFIG

function Get-MyModuleConfig{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    return $config
} Export-ModuleMember -Function Get-MyModuleConfig

function Save-MyModuleConfig{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][Object]$Config
    )

    return Save-Configuration -Config $Config
} Export-ModuleMember -Function Save-MyModuleConfig

function Open-MyModuleConfig{
    [CmdletBinding()]
    param()

    $path = GetConfigFile -Key "config"

    code $path

} Export-ModuleMember -Function Open-MyModuleConfig

function Add-MyModuleConfigAttribute{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet("Account", "User", "Opportunity")][string]$objectType,

        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][string]$Attribute

    )

    begin{
        $config = Get-Configuration
        $configAttribute = ($objectType + "_attributes").ToLower()

        if(-Not $config){
            $config = @{}
        }
    
        if(-Not $config.$configAttribute){
            $config.$configAttribute = @()
        }
    }

    process{
        $config.$configAttribute += $Attribute
    }
    
    End{
        $ret = Save-Configuration -Config $config
        if(-Not $ret){
            throw "Error saving configuration"
        }

        $config = Get-MyModuleConfig
        Write-Output $config.$configAttribute
        
    }

} Export-ModuleMember -Function Add-MyModuleConfigAttribute
