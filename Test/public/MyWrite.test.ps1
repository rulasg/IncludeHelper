function Test_WriteMyHost_Singleline {

    Start-MyTranscript

    Invoke-PrivateContext {
        Write-MyHost -Message "This is a test transcript."
        Write-Host -Message "This is a second test transcript."
    }
    
    $result = Stop-MyTranscript

    Assert-AreEqual -Expected "This is a test transcript." -Presented $result

}

function Test_WriteMyHost_Multiline {

    Start-MyTranscript

    Invoke-PrivateContext {
        Write-MyHost -Message "This is a test transcript 0"
        Write-MyHost -Message "This is a test transcript 1"
    }
    $result = Stop-MyTranscript

    Assert-AreEqual -Expected "This is a test transcript 0" -Presented $result[0]
    Assert-AreEqual -Expected "This is a test transcript 1" -Presented $result[1]
}