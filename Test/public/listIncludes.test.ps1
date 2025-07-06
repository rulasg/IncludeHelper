function Test_GetIncludeFile{
    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"

    $includelist =@()

    @("github","Include","TestInclude","Helper","TestHelper") | ForEach-Object{
        $includelist += Get-ModuleFolder -FolderName $_ | Get-ChildItem -File
    }

    #Act all includes
    $result = Get-IncludeFile

    # Total number
    Assert-Count -Expected $includelist.Count -Presented $result
    # Assert random file
    $item = $result | Where-Object {$_.Name -eq $name}
    Assert-Count -Expected 1 -Presented $item
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName

    # Act filtered
    $result = Get-IncludeFile -Filter "config"
    $includesListFiltered = $includelist | Where-Object {$_.Name -like "*config*"}
    Assert-Count -Expected $includesListFiltered.Count -Presented $result
    # Assert random files
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

    Assert-Count -Expected 17 -Presented $result

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

