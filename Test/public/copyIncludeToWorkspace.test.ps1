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