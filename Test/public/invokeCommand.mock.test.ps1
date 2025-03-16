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