function Test_InvokePrivateFunction{

    # First check that private function call fails
    $errorStr = @"
The term 'Get-PrivateString' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
"@

    $hasthrown = $false
    try{
        Get-PrivateString -Param1 "TestParam"
    } catch {
        $hasthrown = $true
        Assert-AreEqual -Expected $errorStr -Presented $_.Exception.Message
    }
    Assert-IsTrue -Condition $hasthrown


    # Call private function through Invoke-PrivateContext
    Invoke-PrivateContext {

        $result = Get-PrivateString -Param1 "TestParam"

        Assert-AreEqual -Expected "Private string [TestParam]" -Presented $result
    }

}