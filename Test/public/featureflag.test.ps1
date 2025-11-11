function Test_FeatureFlag_Success{
    Mock_Config

    Invoke-PrivateContext{

        $ffName = "ff1"
        $configFilePath = Invoke-MyCommand -Command "Invoke-IncludeHelperGetConfigRootPath" | Join-Path -ChildPath "config.json"

        $result = Test-FeatureFlag -Key $ffName
        Assert-IsFalse -Condition $result

        # Calling Test-FeatureFlag will create entry on config.FeatureFlags
        $config = Get-Content $configFilePath | ConvertFrom-Json -AsHashtable
        Assert-IsFalse -Condition $config.FeatureFlags.$ffName

        Set-FeatureFlag $ffName
        $result = Test-FeatureFlag -Key $ffName
        Assert-IsTrue -Condition $result

        # Set flag adds $true to the config.FeatureFlags
        $config = Get-Content $configFilePath| ConvertFrom-Json -AsHashtable
        Assert-IsTrue -Condition $config.FeatureFlags.$ffName
        
        Clear-FeatureFlag $ffName
        $result = tff $ffName
        Assert-IsFalse -Condition $result

        # Clear flag sets the flag to $false in config.FeatureFlags
        $config = Get-Content $configFilePath| ConvertFrom-Json -AsHashtable
        Assert-IsFalse -Condition $config.FeatureFlags.$ffName
    }
}
