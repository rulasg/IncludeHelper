# DATABASE V2
#
# Database driver to store the cache
#
# Include design description
# This is the function ps1. This file is the same for all modules.
# Create a public psq with variables, Set-MyInvokeCommandAlias call and Invoke public function.
# Invoke function will call back `GetDatabaseRootPath` to use production root path
# Mock this Invoke function with Set-MyInvokeCommandAlias to set the Store elsewhere
# This ps1 has function `GetDatabaseFile` that will call `Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS`
# to use the store path, mocked or not, to create the final store file name.
# All functions of this ps1 will depend on `GetDatabaseFile` for functionality.
#

$MODULE_ROOT_PATH = $PSScriptRoot | Split-Path -Parent
$MODULE_NAME = (Get-ChildItem -Path $MODULE_ROOT_PATH -Filter *.psd1 | Select-Object -First 1).BaseName
$DATABASE_ROOT = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "databaseCache"

$DB_INVOKE_GET_ROOT_PATH_ALIAS = "$($MODULE_NAME)GetDbRootPath"

$function = "Invoke-$($MODULE_NAME)GetDbRootPath"
if(-not (Test-Path -Path function:$function)){
    
    # PUBLIC FUNCTION
    function Invoke-MyModuleGetDbRootPath{
        [CmdletBinding()]
        param()
        
        $databaseRoot = GetDatabaseRootPath
        return $databaseRoot
        
    }
    Rename-Item -path Function:Invoke-MyModuleGetDbRootPath -NewName $function
    Export-ModuleMember -Function $function
    Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $function
}

# Extra functions not needed by INCLUDE DATABASE V2
$function = "Reset-$($MODULE_NAME)DatabaseStore"
if(-not (Test-Path -Path function:$function)){
    function Reset-MyModuleDatabaseStore{
        [CmdletBinding()]
        param()
        
        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS
        
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue
        
        New-Item -Path $databaseRoot -ItemType Directory
        
    }
    
    Rename-Item -path Function:Reset-MyModuleDatabaseStore -NewName $function
    Export-ModuleMember -Function $function
}

# PRIVATE FUNCTIONS
function GetDatabaseRootPath {
    [CmdletBinding()]
    param()

    $databaseRoot = $DATABASE_ROOT
    return $databaseRoot
}

function GetDatabaseFile{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS

    $path = $databaseRoot | Join-Path -ChildPath "$Key.json"

    return $path
}

function Get-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    if(-Not (Test-DatabaseKey $Key)){
        return $null
    }

    $path =  GetDatabaseFile $Key

    $ret = Get-Content $path | ConvertFrom-Json -Depth 10 -AsHashtable

    return $ret
}

function Reset-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )
    $path =  GetDatabaseFile -Key $Key
    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key,
        [Parameter(Position = 2)][Object]$Value
    )

    $path = GetDatabaseFile -Key $Key

    $Value | ConvertTo-Json -Depth 10 | Set-Content $path
}

function Test-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Key
    )

    $path = GetDatabaseFile -Key $Key

    # Key file not exists
    if(-Not (Test-Path $path)){
        return $false
    }

    # TODO: Return $false if cache has expired

    return $true
}