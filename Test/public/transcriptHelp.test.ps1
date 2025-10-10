function Test_transcript{

    Start-MyTranscript

    Write-Host "This is a test transcript."
    Write-Warning "This is a warning message."

    # We don´t assert errors as if failin in Actions pipes while working in local run
    # try {
    #     Write-Error "This is an error message."
    # }
    # catch {}

    Write-Host $result

    Assert-Contains -Expected "This is a test transcript." -Presented $result
    Assert-Contains -Expected "WARNING: This is a warning message." -Presented $result
    # Assert-Contains -Expected "     | This is an error message." -Presented $result
}