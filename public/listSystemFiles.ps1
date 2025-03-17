function Get-IncludeSystemFiles{
    [CmdletBinding()]
    param(
        #add filter pattern
        [Parameter(Mandatory = $false, Position = 0)] [string]$Filter = '*'
    )

    $includeItems =@()
    
    # Root
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'deploy.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'LICENSE' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'module.psm1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'release.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'sync.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'test.ps1' }

    # Tools
    $includeItems += [PSCustomObject]@{ FolderName = 'Tools' ; Name = 'deploy.Helper.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Tools' ; Name = 'sync.Helper.ps1' }

    # TestRoot
    $includeItems += [PSCustomObject]@{ FolderName = 'TestRoot' ; Name = 'Test.psd1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'TestRoot' ; Name = 'Test.psm1' }

    # # TestInclude
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestInclude' ; Name = 'config.mock.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestInclude' ; Name = 'database.mock.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestInclude' ; Name = 'invokeCommand.mock.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestInclude' ; Name = 'module.helper.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestInclude' ; Name = 'ps1.test.helper.ps1' }

    # # TestPublic
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPublic' ; Name = 'include.config.test.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPublic' ; Name = 'include.databasev2.test.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPublic' ; Name = 'include.getHashCode.test.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPublic' ; Name = 'include.module.helper.test.ps1' }

    # # TestPrivate
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPrivate' ; Name = 'include.config.mock.MyModule.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPrivate' ; Name = 'include.database.mock.MyModule.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestPrivate' ; Name = 'include.invokeCommand.MyModule.ps1' }

    # # Include
    # $includeItems += [PSCustomObject]@{ FolderName = 'Include' ; Name = 'config.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'Include' ; Name = 'databaseV2.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'Include' ; Name = 'getHashCode.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'Include' ; Name = 'mySetInvokeCommandAlias.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'Include' ; Name = 'ps1.helper.ps1' }

    # # Public
    # $includeItems += [PSCustomObject]@{ FolderName = 'Public' ; Name = 'include.config.MyModule.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = 'Public' ; Name = 'include.databasev2.MyModule.ps1' }

    # # Private
    # $includeItems += [PSCustomObject]@{ FolderName = 'Private' ; Name = 'include.mySetInvokeCommandAlias.MyModule.ps1' }

    # DevContainer
    $includeItems += [PSCustomObject]@{ FolderName = 'DevContainer' ; Name = 'devcontainer.json' }

    # WorkFlows
    $includeItems += [PSCustomObject]@{ FolderName = 'WorkFlows' ; Name = 'deploy_module_on_release.yml' }
    $includeItems += [PSCustomObject]@{ FolderName = 'WorkFlows' ; Name = 'powershell.yml' }
    $includeItems += [PSCustomObject]@{ FolderName = 'WorkFlows' ; Name = 'test_with_TestingHelper.yml' }

    # GitHub
    $includeItems += [PSCustomObject]@{ FolderName = 'GitHub' ; Name = 'copilot-commit-message-instructions.md' }
    $includeItems += [PSCustomObject]@{ FolderName = 'GitHub' ; Name = 'copilot-instructions.md' }

    # Filter items
    if($Filter -ne '*'){
        $includeItems = $includeItems | Where-Object { $_.Name -like "*$Filter*" }
    }

    return $includeItems
}
Export-ModuleMember -Function Get-IncludeSystemFiles