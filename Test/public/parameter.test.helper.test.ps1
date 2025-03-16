function Test_parameterstest{

    $result = Get-DummyFunction @WarningParameters @InfoParameters @ErrorParameters
    
    Assert-IsTrue -Condition $result
    Assert-Contains -Expected "Warning Message from dummyFunction" -Presented $warningVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar
    Assert-Contains -Expected "Error Message from dummyFunction" -Presented $errorVar
}

function Test_parameterstest_Error{

    # $ErrorActionPreference = 'SilentlyContinue'
    $result = Get-DummyFunction @ErrorParameters @WarningParameters @InfoParameters
    
    Assert-IsTrue -Condition $result
    Assert-Contains -Expected "Warning Message from dummyFunction" -Presented $warningVar
    Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar
}

function Test_parameterstest_Verbose{

    $result = Get-DummyFunction -Verbose 4>&1 @ErrorParameters @WarningParameters @InfoParameters
    Assert-Contains -Presented $result -Expected "True"
    Assert-Contains -Presented $result -Expected "Verbose Message from dummyFunction"
}

function Get-DummyFunction{
    [CmdletBinding()]
    param()

    Assert-AreEqual -Expected "SilentlyContinue" -Presented $ErrorActionPreference
    Assert-AreEqual -Expected "SilentlyContinue" -Presented $WarningPreference
    Assert-AreEqual -Expected "SilentlyContinue" -Presented $InformationPreference

    Write-Error "Error Message from dummyFunction"
    Write-Verbose "Verbose Message from dummyFunction"
    Write-Warning "Warning Message from dummyFunction"
    Write-Information "Information Message from dummyFunction"
    Write-host "Host Message from dummyFunction"

    return $true
}