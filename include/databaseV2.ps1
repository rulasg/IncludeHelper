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
        [Parameter(Mandatory, Position = 0)][string]$Key,
        [Parameter(Position = 1)][ValidateSet("JSON","XML","TXT")][string]$DBFormat = "JSON"
    )

    $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS

    if(-not (Test-Path -Path $databaseRoot)){
        New-Item -Path $databaseRoot -ItemType Directory -Force | Out-Null
    }

    $ext = GetFileExtension -DbFormat $DBFormat

    $path = $databaseRoot | Join-Path -ChildPath "$Key$ext"

    return $path
}

function GetFileExtension{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DbFormat
    )

    switch ($DbFormat.ToUpper()){
        "JSON" { $ret =  ".json" ; Break }
        "XML"  { $ret =  ".xml"  ; Break }
        "TXT"  { $ret =  ".txt"  ; Break }
        default { throw "Unsupported database format $DbFormat" }
    }
    return $ret
}

function Get-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Key,
        [Parameter(Position = 1)][ValidateSet("JSON","XML","TXT")][string]$DBFormat = "JSON"
    )

    if(-Not (Test-DatabaseKey $Key -DBFormat $DBFormat)){
        return $null
    }

    $path =  GetDatabaseFile $Key -DBFormat $DBFormat

    switch ($DBFormat) {
        "JSON" { $ret = Get-Content $path | ConvertFrom-Json ; Break }
        "XML"  { $ret = Import-Clixml -Path $path ; Break }
        "TXT"  { $ret = Get-Content $path ; Break }
        default { throw "Unsupported database format $DbFormat" }
    }

    return $ret
}

function Reset-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Key,
        [Parameter(Position = 1)][ValidateSet("JSON","XML","TXT")][string]$DBFormat = "JSON"
    )
    $path =  GetDatabaseFile -Key $Key -DBFormat $DBFormat
    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    return
}

function Save-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Key,
        [Parameter(Mandatory, Position = 2)][Object]$Value,
        [Parameter(Position = 3)][ValidateSet("JSON","XML","TXT")][string]$DbFormat = "JSON"
    )

    $path = GetDatabaseFile -Key $Key -DBFormat $DbFormat

    switch ($DbFormat) {
        "JSON" { $Value | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8 -Force ; Break }
        "XML"  { $Value | Export-Clixml -Path $path -Force ; Break }
        "TXT"  { $Value | Set-Content -Path $path -Encoding UTF8 -Force ; Break }
        default { throw "Unsupported database format $DbFormat"
        }
    }
}

function Test-DatabaseKey{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Key,
        [Parameter(Position = 1)][ValidateSet("JSON","XML","TXT")][string]$DBFormat = "JSON"
    )

    $path = GetDatabaseFile -Key $Key -DBFormat $DBFormat

    # Key file not exists
    if(-Not (Test-Path $path)){
        return $false
    }

    # TODO: Return $false if cache has expired

    return $true
}


