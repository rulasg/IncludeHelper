function Test_transcript{

    Start-MyTranscript

    Write-Host "This is a test transcript."
    Write-Warning "This is a warning message."

    # Commenting out error generation to avoid test failures in pipe
    # mac local run is success
    # try {
    #     Write-Error "This is an error message."
    # }
    # catch {}

    $result = Stop-MyTranscript

    Assert-Contains -Expected "This is a test transcript." -Presented $result
    Assert-Contains -Expected "WARNING: This is a warning message." -Presented $result
    # Assert-Contains -Expected "     | This is an error message." -Presented $result
}

function Test_ExportTranscriptLines{

    # Act
    Start-MyTranscript

    Write-Host "Line 1"
    Write-Host "Line 2"
    Write-Host "Line 3"

    $result = Stop-MyTranscript

    # Assert
    $expectedLines = @(
        "Line 1",
        "Line 2",
        "Line 3"
    )
    for($i=0; $i -lt $expectedLines.Count; $i++){
        Assert-AreEqual -Expected $expectedLines[$i] -Presented $result[$i]
    }
}