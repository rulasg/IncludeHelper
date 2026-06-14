function Test_UpdateFileVersion_EmptyFile{

    $version = "1.0.0"

    touch "TestFile.ps1"

    # Act
    $result =Update-VersionToFile -Path "TestFile.ps1" -Version $version

    # Assert
    Assert-IsTrue -Condition $result
    Assert-FileVersion -Path "TestFile.ps1" -Version $version
}

function Test_UpdateFileVersion_NoVersion{

    $version = "1.0.0"

    New-Testingfile -Name "TestFile.ps1" -Content $FILE_FACKE_CONTENT

    # Act
    $result =Update-VersionToFile -Path "TestFile.ps1" -Version $version

    # Assert
    Assert-IsTrue -Condition $result
    Assert-FileVersion -Path "TestFile.ps1" -Version $version -Body $FILE_FACKE_CONTENT
}


function Test_UpdateFileVersion_OnlyVersion{

    $version = "3.2.1"

    # Arrange version in file
    $initVersion = "1.0.0"
    $initDate = "1975-02-18"
    $json = @{ Version = $initVersion ; Date = $initDate } | ConvertTo-Json -Compress
    New-Testingfile -Name "TestFile.ps1" -Content $("# $json")
    Assert-FileVersion -Path "TestFile.ps1" -Version $initVersion -Date $initDate

    # Act
    $result =Update-VersionToFile -Path "TestFile.ps1" -Version $version

    # Assert
    Assert-IsTrue -Condition $result
    Assert-FileVersion -Path "TestFile.ps1" -Version $version
}

function Test_UpdateFileVersion_VersionAndBody{

    $version = "3.2.1"

    # Arrange version in file
    $initVersion = "1.0.0"
    $initDate = "1975-02-18"
    $body = $FILE_FACKE_CONTENT
    $json = @{ Version = $initVersion ; Date = $initDate } | ConvertTo-Json -Compress
    New-Testingfile -Name "TestFile.ps1" -Content $("# $json" + "`n" + $body)
    Assert-FileVersion -Path "TestFile.ps1" -Version $initVersion -Date $initDate -Body $body

    # Act
    $result =Update-VersionToFile -Path "TestFile.ps1" -Version $version

    # Assert
    Assert-IsTrue -Condition $result
    Assert-FileVersion -Path "TestFile.ps1" -Version $version -Body $body
}

$FILE_FACKE_CONTENT = @'
# This is text
# Not sure if I will


morethings or less
'@

function Assert-FileVersion{
    param(
        [string]$Path,
        [string]$Version,
        [string]$Date = (Get-Date -Format "yyyy-MM-dd"),
        [string]$Body
    )

    $content = Get-Content -Path $Path | Out-String
    $json = @{
        Version = $Version
        Date = $Date
    } | ConvertTo-Json -Compress

    $expected = "# $json"

    $content = @(Get-Content -Path $Path)

    # Assert first line
    Assert-AreEqual -Expected $expected -Presented $content[0]

    # Assert content if provided
    if(-not [string]::IsNullOrWhiteSpace($Body)){
        $rest = $content | Select-Object -Skip 1
        # join string[] to string
        $rest = $rest -join "`n"
        Assert-AreEqual -Expected $Body -Presented $rest
    }

}