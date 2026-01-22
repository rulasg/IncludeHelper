function Get-IncludeSystemFiles{
    [CmdletBinding()]
    param(
        #add filter pattern
        [Parameter(Mandatory = $false, Position = 0)] [string]$Filter = '*',
        [Parameter()][switch]$Local

    )

    $systemFolders = @(
        # 'Root',
        # 'Include',
        'DevContainer',
        # 'WorkFlows',
        'GitHub',
        # 'Config',
        # 'Helper',
        # 'Private',
        # 'Public',
        # 'Tools',

        # 'TestRoot',
        # 'TestConfig'
        # 'TestInclude',
        # 'TestHelper',
        # 'TestPrivate',
        # 'TestPublic',

        "TestHelperRoot",
        "TestHelperPrivate",
        "TestHelperPublic",

        "VsCode"

    )

    $includeItems = @()
    
    # Get the files from folders that do not know the number of files in them
    $includeItems += Get-IncludeFile -Folders $systemFolders -Local:$Local

    # Root
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Root" -Filter 'deploy.ps1'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Root" -Filter 'LICENSE'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Root" -Filter 'release.ps1'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Root" -Filter 'sync.ps1'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Root" -Filter 'test.ps1'

    # Tools
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Tools" -Filter 'deploy.Helper.ps1'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "Tools" -Filter 'sync.Helper.ps1'

    #TestRoot
    # $includeItems += Get-IncludeFile -Local:$Local -Folders "TestRoot" -Filter 'Test.psd1'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "TestRoot" -Filter 'Test.psm1'

    #WorkFlows
    $includeItems += Get-IncludeFile -Local:$Local -Folders "WorkFlows" -Filter 'deploy_module_on_release.yml'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "WorkFlows" -Filter 'powershell.yml'
    $includeItems += Get-IncludeFile -Local:$Local -Folders "WorkFlows" -Filter 'test_with_TestingHelper.yml'

    # Root
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = 'deploy.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = 'LICENSE' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = '{modulename}.psd1' }
    $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = '{modulename}.psm1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = 'release.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = 'sync.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Root') ; Name = 'test.ps1' }

    # # Tools
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Tools') ; Name = 'deploy.Helper.ps1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'Tools') ; Name = 'sync.Helper.ps1' }

    # TestRoot
    # #$includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'TestRoot') ; Name = 'Test.psd1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'TestRoot') ; Name = 'Test.psm1' }

    # # TestHelperRoot
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'TestHelperRoot') ; Name = 'Test_Helper.psd1' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'TestHelperRoot') ; Name = 'Test_Helper.psm1' }

    # # DevContainer
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'DevContainer') ; Name = 'devcontainer.json' }

    # # WorkFlows
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'WorkFlows') ; Name = 'deploy_module_on_release.yml' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'WorkFlows') ; Name = 'powershell.yml' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'WorkFlows') ; Name = 'test_with_TestingHelper.yml' }

    # # GitHub
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'GitHub') ; Name = 'copilot-commit-message-instructions.md' }
    # $includeItems += [PSCustomObject]@{ FolderName = $(Get-Folder 'GitHub') ; Name = 'copilot-instructions.md' }

    # Filter items
    if($Filter -ne '*'){
        $includeItems = $includeItems | Where-Object { $_.Name -like "*$Filter*" }
    }

    return $includeItems
}
Export-ModuleMember -Function Get-IncludeSystemFiles

function Get-Folder{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][ValidateSet([ValidFolderNames])][string]$FolderName
    )

    return $FolderName
}