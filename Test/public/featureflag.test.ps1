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

function Test_RegisteredFeatureFlags_Success{

    $modulename = "kk"

    # Create Module
    New-ModuleV3 -Name $modulename
    $fullpath = $modulename | Resolve-Path

    # update module with required code to run featureflags in it
    Sync-IncludeWithModule -DestinationModulePath $fullpath
    Get-IncludeFile invokeCommand.helper.ps1 | Add-IncludeToWorkspace -DestinationModulePath $fullpath
    Get-IncludeFile MyWrite.ps1 | Add-IncludeToWorkspace -DestinationModulePath $fullpath
    Get-IncludeFile config.ps1 | Add-IncludeToWorkspace -DestinationModulePath $fullpath
    Get-IncludeFile featureflag.ps1 | Add-IncludeToWorkspace -DestinationModulePath $fullpath
    Get-IncludeFile module.helper.ps1 | Add-IncludeToWorkspace -DestinationModulePath $fullpath
    
    # Add a fake Registered featureflags configuration
    $reg = @{
        deprecated = @(
            'ff1'
            'ff2'
        )
    }
    $reg | ConvertTo-Json | Out-File -FilePath $fullPath/featureflags.json

    # Import module
    Import-Module -Name $fullpath
    # Mock config for module kk
    Mock_Config -ModuleName $modulename -MockPath "kk_config"

    # Set feature flags in the kk config
    Set-kkFeatureFlag ff1
    Set-kkFeatureFlag ff2 -Value $false
    Set-kkFeatureFlag ff3

    # Act - Clear registered deprecated featureflags from config
    Invoke-PrivateContext -ModulePath $fullpath {

        Clear-FeatureFlagsRegistered

    }

    # Assert confirm that deprecated flags are removed and ff3 remains
    $result = Get-kkFeatureFlags

    Assert-Count -Expected 1 -Presented $result.Keys
    Assert-Contains -Expected "ff3" -Presented $result.Keys

}