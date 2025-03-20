function Test_AddIncludeToWorkspace{

    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path

    ## Test for TestInclude
    $name = "invokeCommand.mock.ps1"
    $folderName = "TestInclude"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path
}

function Test_AddIncludeToWorkspace_WithFileTransformation{
    
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    $fileInfo = Get-IncludeSystemFiles -Filter '{modulename}' | Select-Object -First 1
    $destinationName = $fileInfo.Name -replace '{modulename}', 'TestModule'
    $destinationPath = Get-ModuleFolder -FolderName $fileInfo.FolderName -ModuleRootPath "TestModule"
    $destinationFilePath = $destinationPath | Join-Path -ChildPath $destinationName

    # Act
    $fileInfo | Add-IncludeToWorkspace -DestinationModulePath "TestModule"

    # Assert
    Assert-ItemExist -path $destinationFilePath
}

function Test_AddIncludeToWorkspace_PipeParameters{
    
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule
    
    # Test for Include
    $destinationModulePath = "TestModule"
    
    $includesToAdd = @(
        [PSCustomObject]@{ Name = "config.ps1"; FolderName = "Include" },
        [PSCustomObject]@{ Name = "config.mock.ps1"; FolderName = "TestInclude" }
    )

    #Act
    $includesToAdd | Add-IncludeToWorkspace -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName "Include" -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath "config.ps1"
    Assert-ItemExist -path $path
    $folderNamePath = get-Modulefolder -FolderName "TestInclude" -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath "config.mock.ps1"
    Assert-ItemExist -path $path

}

function Test_CopyIncludeToWorkspace{

    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    # Test for Include
    $name = "sync.Helper.ps1"
    $folderPath = "tools"
    $destinationModulePath = "TestModule"

    #Act
    Copy-IncludeToWorkspace -Name $name -FolderPath $folderPath -DestinationModulePath $destinationModulePath

    #Assert
    Assert-ItemExist -path $( $destinationModulePath | Join-Path -ChildPath $folderPath -AdditionalChildPath $name)

    ## Test for TestInclude
    $name = "devcontainer.json"
    $folderPath = ".devcontainer"
    $destinationModulePath = "TestModule"

    #Act
    Copy-IncludeToWorkspace -Name $name -FolderPath $folderPath -DestinationModulePath $destinationModulePath

    #Assert
    Assert-ItemExist -path $( $destinationModulePath | Join-Path -ChildPath $folderPath -AdditionalChildPath $name)

}