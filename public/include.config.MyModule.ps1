
# This file is part of the CONFIG Mock Include.

$CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "MyModuleGetConfigRootPath"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-MyModuleGetConfigRootPath"

Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD

function Invoke-MyModuleGetConfigRootPath{
    $configRoot = GetConfigRootPath
    return $configRoot
} Export-ModuleMember -Function Invoke-MyModuleGetConfigRootPath

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
