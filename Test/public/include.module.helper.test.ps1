function Test_GetTestingModuleName{

    $result = Get-TestedModuleName

    Assert-AreEqual -Expected "IncludeHelper" -Presented $result
}