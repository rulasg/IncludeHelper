function Test_FeatureFlag_Success{
    Mock_Config

    Invoke-PrivateContext{

        $ffName = "ff1"

        $result = Test-FeatureFlag -Key $ffName
        Assert-IsFalse -Condition $result
        
        Set-FeatureFlag $ffName
        $result = Test-FeatureFlag -Key $ffName
        Assert-IsTrue -Condition $result
        
        Clear-FeatureFlag $ffName
        $result = tff $ffName
        Assert-IsFalse -Condition $result
    }
}
