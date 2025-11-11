function Test_ConfigInclude{

    Reset-InvokeCommandMock
    Mock_Config

    # Emput config
    $result = Get-IncludeHelperConfig
    Assert-IsNull -Object $result

    # Add Value String
    $value = "Some value"
    Set-IncludeHelperConfigValue -Name "TestKey" -Value $value
    $result = Get-IncludeHelperConfig
    Assert-AreEqual -Expected $value -Presented $result.TestKey

    # Add Value Hashtable
    $htable = @{ Key1 = "Value1"; Key2 = "Value2" }
    Set-IncludeHelperConfigValue -Name "TestHashtable" -Value $htable
    $result = Get-IncludeHelperConfig
    Assert-AreEqual -Expected $htable.Key1 -Presented $result.TestHashtable.Key1
    Assert-AreEqual -Expected $htable.Key2 -Presented $result.TestHashtable.Key2

    # Previuse value still there
    Assert-AreEqual -Expected $value -Presented $result.TestKey

}

