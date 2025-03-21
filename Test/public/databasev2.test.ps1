
function Test_Database{

    Reset-InvokeCommandMock
    Mock_Database -ResetDatabase

    # Load include files needed to test databaser
    . $(Get-Ps1FullPath -Name "invokeCommand.helper.ps1" -FolderName "helper")
    . $(Get-Ps1FullPath -Name "databaseV2.ps1" -FolderName "Include")

    # Get Default Database Root Path
    $result = GetDatabaseRootPath
    $expected = [System.Environment]::GetFolderPath('UserProfile') | Join-Path -ChildPath ".helpers" -AdditionalChildPath $MODULE_NAME, "databaseCache"
    Assert-AreEqual -Expected $expected -Presented $result

    # Get actual store path
    $StorePath = Invoke-MyCommand -Command "Invoke-IncludeHelperGetDbRootPath"
    Assert-AreEqual -Expected "test_database_path" -Presented $StorePath
    $items = Get-ChildItem -Path $StorePath
    Assert-Count -Expected 0 -Presented $items

    # GetDatabaseFile
    $result = GetDatabaseFile -Key "test"
    Assert-AreEqual -Expected "test_database_path/test.json" -Presented $result

    # Test if database is empty
    $result = Test-DatabaseKey -Key "test"
    Assert-IsFalse -Condition $result
    $result = Get-DatabaseKey -Key "test"
    Assert-IsNull -Object $result

    # Save content to database
    Save-DatabaseKey -Key "test" -Value "dummy content"
    $result = Test-DatabaseKey -Key "test"
    Assert-IsTrue -Condition $result

    $result = Get-DatabaseKey -Key "test"
    Assert-AreEqual -Expected "dummy content" -Presented $result

    # Check the number of files in store
    $items = Get-ChildItem -Path $StorePath
    Assert-Count -Expected 1 -Presented $items

    # Reset Database
    Reset-DatabaseKey -Key "test"
    $result = Test-DatabaseKey -Key "test"
    Assert-IsFalse -Condition $result
}

function Test_Database_MultyKey{

    Reset-InvokeCommandMock
    Mock_Database -ResetDatabase

    # Load include files needed to test databaser
    . $(Get-Ps1FullPath -Name "invokeCommand.helper.ps1" -FolderName "helper")
    . $(Get-Ps1FullPath -Name "databaseV2.ps1" -FolderName "Include")

    # Add several keys
    Save-DatabaseKey -Key "test1" -Value "dummy content 1"
    Save-DatabaseKey -Key "test2" -Value "dummy content 2"
    Save-DatabaseKey -Key "test3" -Value "dummy content 3"
    Save-DatabaseKey -Key "test4" -Value "dummy content 4"
    Save-DatabaseKey -Key "test5" -Value "dummy content 5"

    # Check the number of files in store
    $StorePath = Invoke-MyCommand -Command "Invoke-IncludeHelperGetDbRootPath"
    $items = Get-ChildItem -Path $StorePath
    Assert-Count -Expected 5 -Presented $items

    # Get one key from the middle
    $result = Get-DatabaseKey -Key "test4"
    Assert-AreEqual -Expected "dummy content 4" -Presented $result

    # Test one key from the middle
    $result = Test-DatabaseKey -Key "test4"
    Assert-IsTrue -Condition $result

    # Test a key that does not exists
    $result = Test-DatabaseKey -Key "test6"
    Assert-IsFalse -Condition $result

    # Reset a key that does not exists
    $result = Reset-DatabaseKey -Key "test6"
    Assert-IsNull -Object $result

    # Reset a key that exists
    $result = Reset-DatabaseKey -Key "test4"
    Assert-IsNull -Object $result
    $result = Test-DatabaseKey -Key "test4"
    Assert-IsFalse -Condition $result

}