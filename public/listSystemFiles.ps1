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
    # $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = '{modulename}.psd1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = '{modulename}.psm1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'release.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'sync.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'test.ps1' }

    # Tools
    $includeItems += [PSCustomObject]@{ FolderName = 'Tools' ; Name = 'deploy.Helper.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Tools' ; Name = 'sync.Helper.ps1' }

    # TestRoot
    # $includeItems += [PSCustomObject]@{ FolderName = 'TestRoot' ; Name = 'Test.psd1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'TestRoot' ; Name = 'Test.psm1' }

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
