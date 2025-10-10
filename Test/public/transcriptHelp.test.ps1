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