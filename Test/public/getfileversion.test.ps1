function Test_GetFileVersion_EmptyFile{

    touch "TestFile.ps1"

    # Act
    $result = Get-IncludeFileVersion -Path "TestFile.ps1"
 
    Assert-IsNull -Object $result
}

function Test_GetFileVersion_NoVersion{

    New-Testingfile -Name "TestFile.ps1" -Content $FILE_FACKE_CONTENT

    # Act
    $result = Get-IncludeFileVersion -Path "TestFile.ps1"

    # Assert
    Assert-IsNull -Object $result
}

function Test_GetFileVersion_OnlyVersion{

    # Arrange version in file
    $headerversion = 1
    $version = "1.0.0"
    $date = "1975-02-18"
    $source = "IncludeHelper"

    $json = Build-TestFileVersionJson $Version $Date $source $headerversion
    New-Testingfile -Name "TestFile.ps1" -Content $("# $json")
    Assert-FileVersion -Path "TestFile.ps1" -Version $version -Date $date

    # Act
    $result = Get-IncludeFileVersion -Path "TestFile.ps1"

    # Assert
    Assert-IsNotNull -Object $result
    Assert-AreEqual -Expected $version -Presented $result.Version
    Assert-AreEqual -Expected $date -Presented $result.Date
    Assert-AreEqual -Expected $source -Presented $result.Source
    Assert-AreEqual -Expected $headerversion -Presented $result.HeaderVersion
}

function Test_GetFileVersion_VersionAndBody{

    # Arrange version in file
    $headerversion = 1
    $version = "1.0.0"
    $date = "1975-02-18"
    $source = "IncludeHelper"
    $header = Build-TestVersionHeader $Version $Date $source $headerversion
    $body = $FILE_FACKE_CONTENT
    $content = ($header + $body) -join "`n"
    New-Testingfile -Name "TestFile.ps1" -Content $content
    Assert-FileVersion -Path "TestFile.ps1" -Version $version -Date $date -Body $body 

    # Act
    $result = Get-IncludeFileVersion -Path "TestFile.ps1"

    # Assert
    Assert-IsNotNull -Object $result
    Assert-AreEqual -Expected $version -Presented $result.Version
    Assert-AreEqual -Expected $date -Presented $result.Date
}