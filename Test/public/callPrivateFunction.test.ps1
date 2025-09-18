function Test_InvokePrivateFunction{

    Invoke-PrivateContext{

        $result = Get-PrivateString -Param1 "TestParam"

        Assert-AreEqual -Expected "Private string [TestParam]" -Presented $result
    }

}