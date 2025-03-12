function Test_MockCallToObject{

    Reset-InvokeCommandMock

    $data = @{
        Name = 'Test'
        Value = 42
    }

    MockCallToObject -Command 'Test-Command' -OutObject $data

    $result = Invoke-MyCommand -Command 'Test-Command'

    Assert-AreEqual -Expected 'Test' -Presented $result.Name
    Assert-AreEqual -Expected 42 -Presented $result.Value
}

function Test_MockCallToObject_ResetObject{

    Reset-InvokeCommandMock

    MockCallToObject -Command  'kk1' -OutObject 'Testkk1'
    MockCallToObject -Command  'kk2' -OutObject 'Testkk2'
    MockCallToObject -Command  'kk3' -OutObject 'Testkk3'

    Assert-AreEqual -Expected 'Testkk1' -Presented (Invoke-MyCommand -Command 'kk1')
    Assert-AreEqual -Expected 'Testkk2' -Presented (Invoke-MyCommand -Command 'kk2')
    Assert-AreEqual -Expected 'Testkk3' -Presented (Invoke-MyCommand -Command 'kk3')

    $variables = Get-Variable -scope Global -Name "$($MODULE_INVOKATION_TAG_MOCK)_*"

    Assert-Count -Expected 3 -Presented $variables

    Reset-InvokeCommandMock
    $variables = Get-Variable -scope Global -Name "$($MODULE_INVOKATION_TAG_MOCK)_*"
    Assert-Count -Expected 0 -Presented $variables
}