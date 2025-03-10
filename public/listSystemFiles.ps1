function Get-IncludeSystemFiles{
    [CmdletBinding()]
    param(
        #add filter pattern
        [Parameter(Mandatory = $false, Position = 0)] [string]$Filter = '*'
    )

    $includeItems =@()
    
    # Root
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'module.psm1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'test.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'deploy.ps1' }
    $includeItems += [PSCustomObject]@{ FolderName = 'Root' ; Name = 'release.psd1' }
    
    # Tools
    $includeItems += [PSCustomObject]@{ FolderName = 'Tools' ; Name = 'deploy.Helper.ps1' }


    # TestRoot
    $includeItems += [PSCustomObject]@{ FolderName = 'TestRoot' ; Name = 'Test.psm1' }




    return $includeItems
} Export-ModuleMember -Function Get-IncludeSystemFiles