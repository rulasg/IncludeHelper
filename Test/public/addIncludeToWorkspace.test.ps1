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