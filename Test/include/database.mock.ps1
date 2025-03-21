# DATABASE MOCK 
#
# This file is used to mock the database path and the database file
# for the tests. It creates a mock database path and a mock database file
# and sets the database path to the mock database path.


$moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
$MODULE_NAME = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName
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

        $databaseRoot = Invoke-MyCommand -Command $DB_INVOKE_GET_ROOT_PATH_CMD
    
        Remove-Item -Path $databaseRoot -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $databaseRoot -ItemType Directory

}