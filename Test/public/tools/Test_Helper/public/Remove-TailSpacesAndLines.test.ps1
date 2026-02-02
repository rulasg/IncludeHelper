function Test_RemoveTrailingWhitespace {

    Import-Test_Helper
    # Build expected content line by line to avoid trailing whitespace being stripped
    $expectedLines = @(
        ""
        "    Line with spaces"
        ""
        "          Line with tabs"
        ""
        "Line with no trailing spaces"
    )
    $Expected = $expectedLines -join "`n"

    $contentLines = @(
        "    "
        "    Line with spaces"
        "       "
        "          Line with tabs"
        "   "
        "Line with no trailing spaces"
        ""
        "  "
    )
    $content = $contentLines -join "`n"

    $presentedFile = New-TestingFile -Content $content -PassThru
    Assert-IsTrue -Condition (Test-TailEmptyLines -Path $presentedFile.FullName)
    Assert-IsTrue -Condition (Test-TailSpacesInLines -Path $presentedFile.FullName)

    $expectedFile = New-TestingFile -Content $Expected -PassThru
    Assert-IsFalse -Condition (Test-TailEmptyLines -Path $expectedFile.FullName)
    Assert-IsFalse -Condition (Test-TailSpacesInLines -Path $expectedFile.FullName)

    # Act
    $result = Remove-TailSpacesAndLines -Path $presentedFile.FullName

    # Assert
    Assert-AreEqualPath $presentedFile.FullName $result
    Assert-AreEqualFiles $expectedFile.FullName $result
    Assert-IsFalse -Condition (Test-TailEmptyLines -Path $presentedFile.FullName)
    Assert-IsFalse -Condition (Test-TailSpacesInLines -Path $presentedFile.FullName)
}

function Test_RemoveTrailingWhitespace_Manyfiles {

    Import-Test_Helper


    $contentDirty = "
    Line with spaces
          Line with tabs


"
    $contentClean = "
    Line with spaces

          Line with tabs
"
    New-TestingFile -Content $contentDirty -Name dirty1.txt
    New-TestingFile -Content $contentDirty -Name dirty2.txt
    New-TestingFile -Content $contentDirty -Name dirty3.txt
    New-TestingFile -Content $contentClean -Name clean1.txt
    New-TestingFile -Content $contentClean -Name clean2.txt

    # Act
    $files = Get-ChildItem
    $result = $files | Remove-TailSpacesAndLines

    # Assert
    Assert-Count -Expected 3 -Presented $result

}

function Test_RemoveTrailingWhitespace_NoPath {

    Import-Test_Helper


    $contentDirty = "
    Line with spaces
          Line with tabs


"
    $contentClean = "
    Line with spaces

          Line with tabs
"
    New-TestingFile -Content $contentDirty -Name dirty1.txt
    New-TestingFile -Content $contentDirty -Name dirty2.txt
    New-TestingFile -Content $contentDirty -Name dirty3.txt
    New-TestingFile -Content $contentDirty -Name dirty4.txt -Path kk1
    New-TestingFile -Content $contentClean -Name clean1.txt
    New-TestingFile -Content $contentClean -Name clean2.txt
    New-TestingFile -Content $contentClean -Name clean3.txt -Path kk2

    # Act
    $result = Remove-TailSpacesAndLines

    # Assert
    Assert-Count -Expected 3 -Presented $result

}

function Test_RemoveTrailingWhitespace_NoPath_Recursive {

    Import-Test_Helper


    $contentDirty = "
    Line with spaces
          Line with tabs


"
    $contentClean = "
    Line with spaces

          Line with tabs
"
    New-TestingFile -Content $contentDirty -Name dirty1.txt -Path kk1
    New-TestingFile -Content $contentDirty -Name dirty2.txt
    New-TestingFile -Content $contentDirty -Name dirty3.txt -Path kk2/subkk
    New-TestingFile -Content $contentClean -Name clean1.txt
    New-TestingFile -Content $contentClean -Name clean2.txt

    # Act
    $result = Remove-TailSpacesAndLines -Recurse

    # Assert
    Assert-Count -Expected 3 -Presented $result

}

function Import-Test_Helper{

    $modulepath = Get-ModuleRootPath
    $testhelpermodulepath = $modulepath | Join-Path -ChildPath "tools" -AdditionalChildPath "Test_Helper"
    Import-Module $testhelpermodulepath -Force
}

function Assert-AreEqualFiles {
    param (
        [Parameter(Mandatory, Position = 0)][string] $Expected,
        [Parameter(Mandatory, Position = 1)][string] $Presented
        )

    process {
        $content1 = Get-Content -Path $Expected
        $content2 = Get-Content -Path $Presented


        if($content1.Count -ne $content2.Count) {
            Write-Error "Files have different number of lines"
            return $false
        }

        foreach($i in 0..($content1.Count - 1)) {
            if($content1[$i] -ne $content2[$i]) {
                Write-Error "Files differ at line $($i + 1)"
                return $false
            }
        }

        return $true

    }
}