# Test for Open-Url function
# Open-Url is not exported, so we use Invoke-PrivateContext to call it.
# Open-Url uses Invoke-MyCommand with alias "OpenUrl" to dispatch URL opening.
# We mock the OpenUrl alias to echo back the URL for verification.

function Test_OpenUrl_SingleUrl {
    # Arrange
    Reset-InvokeCommandMock
    $url = "https://github.com"
    $tag = New-Guid

    $command = 'Invoke-{modulename}OpenUrl -Url "{url}"'
    $command = $command -replace "{modulename}", $MODULE_NAME
    $command = $command -replace "{url}", $url
    Set-InvokeCommandMock -Alias $command -Command "echo $tag"

    # Act
    $result = Invoke-PrivateContext {
        param($Arguments)

        Open-Url -Url $Arguments[0]

    } -Arguments $url

    # Assert
    Assert-AreEqual -Expected $tag -Presented $result
}

function Test_OpenUrl_MultipleUrls_Pipeline {
    # Arrange
    Reset-InvokeCommandMock
    $url1 = "https://github.com"
    $url2 = "https://google.com"
    $url3 = "https://microsoft.com"
    $tag1 = New-Guid
    $tag2 = New-Guid
    $tag3 = New-Guid

    foreach ($pair in @(@($url1, $tag1), @($url2, $tag2), @($url3, $tag3))) {
        $command = 'Invoke-{modulename}OpenUrl -Url "{url}"'
        $command = $command -replace "{modulename}", $MODULE_NAME
        $command = $command -replace "{url}", $pair[0]
        Set-InvokeCommandMock -Alias $command -Command "echo $($pair[1])"
    }

    # Act
    $result = Invoke-PrivateContext {
        param($Arguments)

        $Arguments | ForEach-Object { Open-Url -Url $_ }

    } -Arguments @($url1, $url2, $url3)

    # Assert
    Assert-Count -Expected 3 -Presented $result
    Assert-AreEqual -Expected $tag1 -Presented $result[0]
    Assert-AreEqual -Expected $tag2 -Presented $result[1]
    Assert-AreEqual -Expected $tag3 -Presented $result[2]
}