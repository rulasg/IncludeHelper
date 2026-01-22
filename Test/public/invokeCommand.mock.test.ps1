
function Test_MockCallJson{

    Reset-InvokeCommandMock

    $fileName = 'test.json'

    MockCallJson -Command 'Test-Command' -filename $fileName

    $result = Invoke-MyCommand -Command 'Test-Command'

    Assert-IsTrue -Condition ($result -is [PSCustomObject])
    Assert-AreEqual -Expected 'Test' -Presented $result.Name
    Assert-AreEqual -Expected 42 -Presented $result.Value
}

function Test_MockCallJson_AsHashtable{

    Reset-InvokeCommandMock

    $fileName = 'test.json'

    # Act
    MockCallJson -Command 'Test-Command' -filename $fileName -AsHashtable

    # Assert invoking mock command
    $result = Invoke-MyCommand -Command 'Test-Command'

    Assert-IsTrue -Condition ($result -is [hashtable])
    Assert-AreEqual -Expected 'Test' -Presented $result.Name
    Assert-AreEqual -Expected 42 -Presented $result.Value
}

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

function Test_MockCallToObject_ResetMockObject{

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

function Test_MockCallExpression{

    Reset-InvokeCommandMock

    $expression = @'
    echo "new string from mock 2"
    echo "more things to say"
'@

    MockCallExpression -Command "aliasComand" -Expression $expression

    $result = Invoke-MyCommand -Command 'aliasComand'

    Assert-Count -Presented $result -Expected 2
    Assert-Contains -Presented $result -Expected 'new string from mock 2'
    Assert-Contains -Presented $result -Expected 'more things to say'
}

function Test_TraceInvokeCOmmandAlias{


    $fileName = "traceInvoke.log"
    Assert-ItemNotExist -Path $fileName

    # Set flag
    touch $fileName
    $fileNamePath = $fileName | Resolve-Path
    $env:TraceInvokeMockFilePath = $fileNamePath
    Assert-ItemExist -Path $fileNamePath

    # Act record invoke alias
    Set-InvokeCommandMock -alias "fakeAlias1" -Command 'echo "hello from fakeAlias1"'
    Set-InvokeCommandMock -alias "fakeAlias2" -Command 'echo "hello from fakeAlias2"'

    # Assert the two new alias are recorded
    $content = Get-Content $fileNamePath
    Assert-Count -Expected 2 -Presented $content
    Assert-Contains -Presented $content -Expected 'fakeAlias1'
    Assert-Contains -Presented $content -Expected 'fakeAlias2'

    # Assert no duplicate alias are recorded
    Set-InvokeCommandMock -alias "fakeAlias1" -Command 'echo "hello from fakeAlias1"'
    $content = Get-Content $fileNamePath
    Assert-Count -Expected 2 -Presented $content

    # Assert new alias are recorded
    Set-InvokeCommandMock -alias "fakeAlias3" -Command 'echo "hello from fakeAlias1"'
    $content = Get-Content $fileNamePath
    Assert-Count -Expected 3 -Presented $content
}