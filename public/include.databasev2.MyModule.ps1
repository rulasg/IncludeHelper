# This file is required for INCLUDE DATABASE V2

$DB_INVOKE_GET_ROOT_PATH_ALIAS = "MyModuleGetDbRootPath"
$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-MyModuleGetDbRootPath"

Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $DB_INVOKE_GET_ROOT_PATH_CMD

function Invoke-MyModuleGetDbRootPath{
    [CmdletBinding()]
    param()

    $databaseRoot = GetDatabaseRootPath
    return $databaseRoot

} Export-ModuleMember -Function Invoke-MyModuleGetDbRootPath

# Extra functions not needed by INCLUDE DATABASE V2

function Reset-MyModuleDatabaseStore{
    [CmdletBinding()]
    param()

        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

} Export-ModuleMember -Function Reset-MyModuleDatabaseStore