function Test_WriteMyHost_Singleline {

    Start-MyTranscript

    Invoke-PrivateContext {
        Write-MyHost -Message "This is a test transcript."
    }

    $result = Stop-MyTranscript

    Assert-AreEqual -Expected "This is a test transcript." -Presented $result

}

function Test_WriteMyHost_Multiline {

    Start-MyTranscript

    Invoke-PrivateContext {
        Write-MyHost -Message "This is a test transcript 0"
        Write-MyHost -Message "This is a test transcript 1"
    }
    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-AreEqual -Expected "This is a test transcript 0" -Presented $result[0]
    Assert-AreEqual -Expected "This is a test transcript 1" -Presented $result[1]
}

function Test_EnableMyDebug_Set{
    # Arrange
    Disable-IncludeHelperDebug
    # Act
    Enable-IncludeHelperDebug
    # Assert
    Assert-DebugEnv "all" ""
    
    # Arrange
    Disable-IncludeHelperDebug
    # Act
    Enable-IncludeHelperDebug -Sections "section0","section1"
    # Assert
    Assert-DebugEnv "section0 section1" ""

    # Arrange
    Disable-IncludeHelperDebug
    # Act
    Enable-IncludeHelperDebug -Sections "-section0-tofilter"
    # Assert
    Assert-DebugEnv "-section0-tofilter" ""

    # Arrange
    Disable-IncludeHelperDebug
    # Act
    Enable-IncludeHelperDebug -Sections "-section0-tofilter","-section1-tofilter"
    # Assert
    Assert-DebugEnv "-section0-tofilter -section1-tofilter" ""

    # Arrange
    Disable-IncludeHelperDebug
    $logfilename = "testlog.log"
    # Act
    Enable-IncludeHelperDebug -LoggingFilePath $logfilename
    # Assert
    Assert-DebugEnv "" ""

    # Arrange
    Disable-IncludeHelperDebug
    # Act
    New-TestingFile -Name $logfilename
    Enable-IncludeHelperDebug -LoggingFilePath $logfilename
    # Assert
    Assert-DebugEnv "all" $logfilename

}

function Test_EnableMyDebug_All{

    Enable-IncludeHelperDebug

    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG")
    Assert-AreEqual -Expected "all" -Presented $result

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"

    Start-MyTranscript

     Invoke-PrivateContext {
        param($Arguments)
        
        Write-MyDebug -Message $Arguments[0] 
        Write-MyDebug -Message $Arguments[1]

     } -Arguments $text0,$text1

    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-DbgMsg $result[0] "none" $text0
    Assert-DbgMsg $result[1] "none" $text1

}



function Test_EnableMyDebug_All_Sections{

    Enable-IncludeHelperDebug

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"

    Start-MyTranscript

    Invoke-PrivateContext {
        param($Arguments)
    
        Write-MyDebug -Message $Arguments[0] -Section "section0"
        Write-MyDebug -Message $Arguments[1] -Section "section1"

    } -Arguments $text0,$text1

    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-DbgMsg $result[0] "section0" $text0
    Assert-DbgMsg $result[1] "section1" $text1
}

function Test_EnableMyDebug_Sections{

    Enable-IncludeHelperDebug -Sections "section0","section2"

    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG")
    Assert-AreEqual -Expected "section0 section2" -Presented $result

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"
    $text2 = "Debug message 2"

    Start-MyTranscript

        Invoke-PrivateContext {
        param($Arguments)
        
        Write-MyDebug -Message $Arguments[0] -Section "section0"
        Write-MyDebug -Message $Arguments[1] -Section "section1"
        Write-MyDebug -Message $Arguments[2] -Section "section2"

        } -Arguments $text0,$text1,$text2   

    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-DbgMsg $result[0] "section0" $text0
    Assert-DbgMsg $result[1] "section2" $text2
}

function Test_EnableMyDebug_All_Filter{

    Enable-IncludeHelperDebug -Sections "-section1-tofilter"

    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG")
    Assert-AreEqual -Expected "-section1-tofilter" -Presented $result

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"
    $text2 = "Debug message 2"

    Start-MyTranscript

        Invoke-PrivateContext {
        param($Arguments)
        
        Write-MyDebug -Message $Arguments[0] -Section "section0"
        Write-MyDebug -Message $Arguments[1] -Section "section1-tofilter"
        Write-MyDebug -Message $Arguments[2] -Section "section2"

        } -Arguments $text0,$text1,$text2   

    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-DbgMsg $result[0] "section0" $text0
    Assert-DbgMsg $result[1] "section2" $text2
}

function Test_EnableMyDebug_All_Filter_morethanone{

    Enable-IncludeHelperDebug -Sections "-section1-tofilter -section2ToFilter"

    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG")
    Assert-AreEqual -Expected "-section1-tofilter -section2ToFilter" -Presented $result

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"
    $text2 = "Debug message 2"
    $text3 = "Debug message 3"

    Start-MyTranscript

        Invoke-PrivateContext {
        param($Arguments)
        
        Write-MyDebug -Message $Arguments[0] -Section "section0"
        Write-MyDebug -Message $Arguments[1] -Section "section1-tofilter"
        Write-MyDebug -Message $Arguments[2] -Section "section2ToFilter"
        Write-MyDebug -Message $Arguments[3] -Section "section3"

        } -Arguments $text0,$text1,$text2 ,$text3

    $result = Stop-MyTranscript

    Assert-Count -Expected 2 -Presented $result
    Assert-DbgMsg $result[0] "section0" $text0
    Assert-DbgMsg $result[1] "section3" $text3
}

function Test_EnableMyDebug_All_LoggingFilePath{

    $logfilename = "testlog.log"
    touch $logfilename

    Enable-IncludeHelperDebug -LoggingFilePath $logfilename 

    $text0 = "Debug message 0"
    $text1 = "Debug message 1"
    $text2 = "Debug message 2"
    $text3 = "Debug message 3"

    Start-MyTranscript

        Invoke-PrivateContext {
        param($Arguments)
        
        Write-MyDebug -Message $Arguments[0] -Section "section0"
        Write-MyDebug -Message $Arguments[1] -Section "section1-tofilter"
        Write-MyDebug -Message $Arguments[2] -Section "section2ToFilter"
        Write-MyDebug -Message $Arguments[3] -Section "section3"

        } -Arguments $text0,$text1,$text2 ,$text3

    $result = Stop-MyTranscript

    Assert-Count -Expected 4 -Presented $result

    $result = Get-Content $logfilename
    Assert-Count -Expected 4 -Presented $result
    Assert-DbgMsg $result[0] "section0" $text0
    Assert-DbgMsg $result[1] "section1-tofilter" $text1
    Assert-DbgMsg $result[2] "section2ToFilter" $text2
    Assert-DbgMsg $result[3] "section3" $text3
}

function Assert-DbgMsg($Presented,$Section,$Message){
    
    Assert-IsTrue -Condition ($Presented -match "^\[\d{2}:\d{2}:\d{2}\.\d{3}\]\[D\]\[$Section\] $Message$")
}

function Assert-DebugEnv($SectionString,$LoggingFile){
    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG")
    $result = $result ?? ""
    Assert-AreEqual -Expected $SectionString -Presented $result

    $result = [System.Environment]::GetEnvironmentVariable("IncludeHelper_DEBUG_LOGGING_FILEPATH")
    $result = $result ?? ""
    Assert-AreEqual -Expected $LoggingFile -Presented $result
}