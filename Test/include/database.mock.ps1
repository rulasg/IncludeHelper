# DATABASE MOCK 
#
# This file is used to mock the database path and the database file
# for the tests. It creates a mock database path and a mock database file
# and sets the database path to the mock database path.
# We need to define variables for this include to work
# $MOCK_DATABASE_PATH : The path used as the mock database folder
# $DB_INVOKE_GET_ROOT_PATH_CMD : Invoke command that is needed to be mocked
# $DB_INVOKE_GET_ROOT_PATH_ALIAS : Invoke function to retreive the root path of the database
#
# Sample file
# # DATABASE MOCK VARIABLES
# # This file is required for DATABASE MOCK to work
# $DB_INVOKE_GET_ROOT_PATH_ALIAS = "MyModuleGetDbRootPath"
#

$DB_INVOKE_GET_ROOT_PATH_CMD = "Invoke-$DB_INVOKE_GET_ROOT_PATH_ALIAS"
$MOCK_DATABASE_PATH = "test_database_path"

function Mock_Database([switch]$ResetDatabase){

    MockCallToString $DB_INVOKE_GET_ROOT_PATH_CMD -OutString "test_database_path"

    $dbstore = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    Assert-AreEqual -Expected "test_database_path" -Presented $dbstore

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

        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_ALIAS
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

}