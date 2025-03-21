function Test_ConfigInclude{
    Reset-InvokeCommandMock
    Mock_Config

    # Emput config
    $result = Get-IncludeHelperConfig
    Assert-IsNull -Object $result

    # Add acount
    Add-IncludeHelperConfigAttribute -objectType "Account" -Attribute "acountattribute"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 1 -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute" -Presented $result.account_attributes
    Add-IncludeHelperConfigAttribute -objectType "Account" -Attribute "acountattribute2"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 2 -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute" -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute2" -Presented $result.account_attributes

    # Add user
    Add-IncludeHelperConfigAttribute -objectType "User" -Attribute "userattribute"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 1 -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute" -Presented $result.user_attributes
    Add-IncludeHelperConfigAttribute -objectType "User" -Attribute "userattribute2"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 2 -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute" -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute2" -Presented $result.user_attributes

    # Add Opportunity
    Add-IncludeHelperConfigAttribute -objectType "Opportunity" -Attribute "opportunityattribute"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 1 -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute" -Presented $result.opportunity_attributes
    Add-IncludeHelperConfigAttribute -objectType "Opportunity" -Attribute "opportunityattribute2"
    $result = Get-IncludeHelperConfig
    Assert-Count -Expected 2 -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute" -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute2" -Presented $result.opportunity_attributes

}

