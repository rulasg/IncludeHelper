# This file is required for INCLUDE DATABASE V2

$DB_INVOKE_GET_ROOT_PATH_ALIAS = "IncludeHelperGetDbRootPath"
# $DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-$MyModuleGetDbRootPath"

# Set-MyInvokeCommandAlias -Alias $DB_INVOKE_GET_ROOT_PATH_ALIAS -Command $DB_INVOKE_GET_ROOT_PATH_CMD

# function Invoke-MyModuleGetDbRootPath{
#     [CmdletBinding()]
#     param()

#     $databaseRoot = GetDatabaseRootPath
#     return $databaseRoot

# }
# Rename-Item -path Function:Invoke-MyModuleGetDbRootPath -NewName $DB_INVOKE_GET_ROOT_PATH_CMD
# Export-ModuleMember -Function $DB_INVOKE_GET_ROOT_PATH_CMD

# # Extra functions not needed by INCLUDE DATABASE V2

# function Reset-MyModuleDatabaseStore{
#     [CmdletBinding()]
#     param()

#         $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS
    
#         Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

#         New-Item -Path $databaseRoot -ItemType Directory

# }
# Rename-Item -path Function:Reset-MyModuleDatabaseStore -NewName "Reset-$DB_INVOKE_GET_ROOT_PATH_ALIAS"
# Export-ModuleMember -Function "Reset-$DB_INVOKE_GET_ROOT_PATH_ALIAS"