function Test_GetIncludeFile{
    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"

    #Act
    $result = Get-IncludeFile

    #Assert
    $item = $result | Where-Object {$_.Name -eq $name}
    Assert-Count -Expected 1 -Presented $item
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName

    # Filtered
    $result = Get-IncludeFile -Filter "config"
    Assert-Count -Expected 2 -Presented $result
    $item = $result | Where-Object {$_.Name -eq "config.ps1"}
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName
    $item = $result | Where-Object {$_.Name -eq "config.mock.ps1"}
    Assert-AreEqual -Expected "TestInclude" -Presented $item.FolderName

}

function Test_GetIncludeSystemFiles {
    # Test for IncludeSystemFiles
    $name = "deploy.ps1"
    $folderName = "Root"

    # Act
    $result = Get-IncludeSystemFiles

    Assert-Count -Expected 16 -Presented $result

    # Assert
    $item = $result | Where-Object {$_.Name -eq $name}
    Assert-Count -Expected 1 -Presented $Item
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName

    # Filtered
    $result = Get-IncludeSystemFiles -Filter "testing"
    Assert-Count -Expected 1 -Presented $result
    $item = $result | Where-Object {$_.Name -eq "test_with_TestingHelper.yml"}
    Assert-AreEqual -Expected "WorkFlows" -Presented $item.FolderName
}

