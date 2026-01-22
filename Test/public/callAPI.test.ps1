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

function Test_Call_API_GraphQL{

    Assert-SkipTest "This test is not implemented"

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $query = @'
    query UserOrgOwner($login:String!){
        organization(login: $login){login,id}
        }
'@
    $variables = @{login = "octodemo"}

    $result = Invoke-GraphQL -Query $query -variables $variables

    Assert-AreEqual -Presented $result.data.organization.id -Expected "MDEyOk9yZ2FuaXphdGlvbjM4OTQwODk3"

}

function Test_Call_API_GraphQL_outfile{

    Assert-SkipTest "This test is not implemented"

    Reset-InvokeCommandMock
    Enable-InvokeCommandAliasModule

    $file = "outfile.json"

    $query = @'
    query UserOrgOwner($login:String!){
        organization(login: $login){login,id}
        }
'@
    $variables = @{login = "octodemo"}

    $result = Invoke-GraphQL -Query $query -variables $variables -OutFile $file

    Assert-ItemExist -Path $file

    $result = Get-Content $file | ConvertFrom-Json -Depth 10

    Assert-AreEqual -Presented $result.data.organization.id -Expected "MDEyOk9yZ2FuaXphdGlvbjM4OTQwODk3"
}