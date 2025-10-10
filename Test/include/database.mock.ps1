# DATABASE MOCK 
#
# This file is used to mock the database path and the database file
# for the tests. It creates a mock database path and a mock database file
# and sets the database path to the mock database path.
#
# THIS INCLUDE REQURED module.helper.ps1
if(-not $MODULE_NAME){ throw "Missing MODULE_NAME varaible initialization. Check for module.helerp.ps1 file." }

$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-$($MODULE_NAME)GetDbRootPath"
$MOCK_DATABASE_PATH = "test_database_path"

function Mock_Database([switch]$ResetDatabase){

    MockCallToString $DB_INVOKE_GET_ROOT_PATH_CMD -OutString $MOCK_DATABASE_PATH

    $dbstore = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    Assert-AreEqual -Expected $MOCK_DATABASE_PATH -Presented $dbstore

    if($ResetDatabase){
        Reset-DatabaseStore
    }

}

function Get-Mock_DatabaseStore{
    $dbstore = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    return $dbstore
}

function Reset-DatabaseStore{
    [CmdletBinding()]
    param()

        # Get actual store path
        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD

        # Remove the database root directory
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue
}