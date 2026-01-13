
function Test_parameterstest{

    Enable-IncludeHelperVerbose
    Start-MyTranscript
    $result = Get-DummyFunction @ErrorParameters @WarningParameters @InfoParameters
    $tt = Stop-MyTranscript
    Disable-IncludeHelperVerbose

    # Assert result
    Assert-IsTrue -Condition $result
    Assert-Contains -Expected "Error Message from dummyFunction" -Presented $errorVar[0].exception.Message
    Assert-Contains -Expected "Warning Message from dummyFunction" -Presented $warningVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar

    # Not displaied
    Assert-NotContains -Presented $tt -Expected "Error Message from dummyFunction"
    Assert-NotContains -Presented $tt -Expected "Warning Message from dummyFunction"
    Assert-NotContains -Presented $tt -Expected "Information Message from dummyFunction"

    # Host message
    Assert-Contains -Presented $tt -Expected "Host Message from dummyFunction"
}

function Test_parameterstest_Verbose{

    Enable-IncludeHelperVerbose
    Start-MyTranscript
    $result = Get-DummyFunction @ErrorParameters @WarningParameters @InfoParameters -Verbose
    $tt = Stop-MyTranscript
    Disable-IncludeHelperVerbose

    # Assert result
    Assert-IsTrue -Condition $result
    Assert-Contains -Expected "Error Message from dummyFunction" -Presented $errorVar[0].exception.Message
    Assert-Contains -Expected "Warning Message from dummyFunction" -Presented $warningVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar

    # Not displaied
    Assert-NotContains -Presented $tt -Expected "Error Message from dummyFunction"
    Assert-NotContains -Presented $tt -Expected "Warning Message from dummyFunction"
    Assert-NotContains -Presented $tt -Expected "Information Message from dummyFunction"

    # Host message
    Assert-Contains -Presented $tt -Expected "VERBOSE: Verbose Message from dummyFunction"
    Assert-Contains -Presented $tt -Expected "Host Message from dummyFunction"
}

function Get-DummyFunction{
    [CmdletBinding()]
    param()

    Write-Error "Error Message from dummyFunction"
    Write-Verbose "Verbose Message from dummyFunction"
    Write-Warning "Warning Message from dummyFunction"
    Write-Information "Information Message from dummyFunction"
    Write-host "Host Message from dummyFunction"

    return $true
}