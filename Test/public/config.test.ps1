function Test_ConfigInclude{

    Mock_Config

    Set-IncludeHelperConfigValue -Name "config_name" -Value "test_config_value"

    $result = Get-IncludeHelperConfig

    Assert-AreEqual -Expected "test_config_value" -Presented $result.config_name

}

