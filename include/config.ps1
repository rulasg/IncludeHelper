# CONFIG
#
# Configuration management module
#
# Include design description
# This is the function ps1. This file is the same for all modules.
# Create a public psq with variables, Set-MyInvokeCommandAlias call and Invoke public function.
# Invoke function will call back `GetConfigRootPath` to use production root path
# Mock this Invoke function with Set-MyInvokeCommandAlias to set the Store elsewhere
# This ps1 has function `GetConfigFile` that will call `Invoke-MyCommand -Command $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS`
# to use the store path, mocked or not, to create the final store file name.
# All functions of this ps1 will depend on `GetConfigFile` for functionality.
#

# MODULE_NAME
$MODULE_NAME = ($PSScriptRoot | Split-Path -Parent | Get-ChildItem -Filter *.psd1 | Select-Object -First 1).BaseName
if(-Not $MODULE_NAME){ throw "Module name not found. Please check the module structure." }

$CONFIG_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "config"

# Create the config root if it does not exist
if(-Not (Test-Path $CONFIG_ROOT)){
    New-Item -Path $CONFIG_ROOT -ItemType Directory
}

function GetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = $CONFIG_ROOT
    return $configRoot
}

function GetConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Key
    )

    $configRoot = Invoke-MyCommand -Command $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS
    $path = Join-Path -Path $configRoot -ChildPath "$Key.json"
    return $path
}

function Test-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    $path = GetConfigFile -Key $Key

    return Test-Path $path
}

function Get-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config"
    )

    $path = GetConfigFile -Key $Key

    if(-Not (Test-Configuration -Key $Key)){
        return $null
    }

    try{
        $ret = Get-Content $path | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        return $ret
    }
    catch{
        Write-Warning "Error reading configuration ($Key) file: $($path). $($_.Exception.Message)"
        return $null
    }
}

function Save-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key = "config",
        [Parameter(Mandatory = $true, Position = 1)][Object]$Config
    )

    $path = GetConfigFile -Key $Key

    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $path -ErrorAction Stop
    }
    catch {
        Write-Warning "Error saving configuration ($Key) to file: $($path). $($_.Exception.Message)"
        return $false
    }

    return $true
}

############


# Define unique aliases for "MyModule"
$CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "$($MODULE_NAME)GetConfigRootPath"
$CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-$($MODULE_NAME)GetConfigRootPath"

# Set the alias for the root path command
Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD

# Define the function to get the configuration root path
function Invoke-MyModuleGetConfigRootPath {
    [CmdletBinding()]
    param()

    $configRoot = GetConfigRootPath
    return $configRoot
}
$function = "Invoke-MyModuleGetConfigRootPath"
$NewName = $function -Replace "MyModule", $MODULE_NAME
Rename-Item -path Function:$Function -NewName $NewName
Export-ModuleMember -Function $NewName

# Extra functions not needed by INCLUDE CONFIG

function Get-MyModuleConfig{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    return $config
} 
$function = "Get-MyModuleConfig"
$NewName = $function -Replace "MyModule", $MODULE_NAME
Rename-Item -path Function:$Function -NewName $NewName
Export-ModuleMember -Function $NewName

function Save-MyModuleConfig{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][Object]$Config
    )

    return Save-Configuration -Config $Config
} $function = "Save-MyModuleConfig"
$NewName = $function -Replace "MyModule", $MODULE_NAME
Rename-Item -path Function:$Function -NewName $NewName
Export-ModuleMember -Function $NewName

function Open-MyModuleConfig{
    [CmdletBinding()]
    param()

    $path = GetConfigFile -Key "config"

    code $path

} $function = "Open-MyModuleConfig"
$NewName = $function -Replace "MyModule", $MODULE_NAME
Rename-Item -path Function:$Function -NewName $NewName
Export-ModuleMember -Function $NewName

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

        $config = Get-Configuration
        Write-Output $config.$configAttribute
        
    }

} $function = "Add-MyModuleConfigAttribute"
$NewName = $function -Replace "MyModule", $MODULE_NAME
Rename-Item -path Function:$Function -NewName $NewName
Export-ModuleMember -Function $NewName










