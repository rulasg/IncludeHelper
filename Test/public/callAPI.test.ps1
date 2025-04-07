function Test_CallAPI_RESTAPI_Withpagination_1{

    Assert-SkipTest "This test is not implemented"
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    # Act
    $result = Invoke-RestAPI -Api "/orgs/octodemo/credential-authorizations" 

    Assert-Count -Expected 31 -Presented $result

    $PAT = $result | Where-Object {$_.credential_type -eq "personal access token"}

    Assert-Count -Expected 2 -Presented $PAT

    Assert-NotImplemented
}

function Test_CallAPI_RESTAPI_Withpagination_2{

    Assert-SkipTest "This test is not implemented"
    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    # Act
    $result = Invoke-RestAPI -Api "issues"
    Assert-Count -Expected 98 -Presented $result

    Assert-NotImplemented
}