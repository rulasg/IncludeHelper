function Test_GetIncludeFile{
    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"

    #Act
    $result = Get-IncludeFile

    Assert-Count -Expected 10 -Presented $result

    #Assert
    $item = $result | Where-Object {$_.Name -eq $name}
    Assert-Count -Expected 1 -Presented $Item
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName

    # Filtered
    $result = Get-IncludeFile -Filter "config"
    Assert-Count -Expected 2 -Presented $result
    $item = $result | Where-Object {$_.Name -eq "config.ps1"}
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName
    $item = $result | Where-Object {$_.Name -eq "config.mock.ps1"}
    Assert-AreEqual -Expected "TestInclude" -Presented $item.FolderName

}

