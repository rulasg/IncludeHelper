function Sync-IncludeWithModule{
    [CmdletBinding()]
    param()

    Get-IncludeFile | Add-IncludeToWorkspace -IfExists

    Get-IncludeSystemFiles | Add-IncludeToWorkspace -IfExists

} Export-ModuleMember -Function Sync-IncludeWithModule