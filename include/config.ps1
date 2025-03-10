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
# TODO : Create a related public ps1 
#
# Create a related public ps1 
# 1. define $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS. Make it unique.
# 2. define $CONFIG_INVOKE_GET_ROOT_PATH_CMD. Point to the invoke function that calls GetConfigRootPath to get the store path
#
# Sample code (replace "MyModule" with a unique module prefix):
#   $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS = "MyModuleGetConfigRootPath"
#   $CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-MyModuleGetConfigRootPath"
#  
#   Set-MyInvokeCommandAlias -Alias $CONFIG_INVOKE_GET_ROOT_PATH_ALIAS -Command $CONFIG_INVOKE_GET_ROOT_PATH_CMD
#  
#   function Invoke-MyModuleGetConfigRootPath{
#       $configRoot = GetConfigRootPath
#       return $configRoot
#   } Export-ModuleMember -Function Invoke-MyModuleGetConfigRootPath


$moduleRootPath = $PSScriptRoot | Split-Path -Parent
$moduleName = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName
$CONFIG_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $moduleName, "config"

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










