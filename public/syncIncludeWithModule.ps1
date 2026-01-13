function Sync-IncludeWithModule{
    [CmdletBinding()]
    param(
        [Parameter()][string]$DestinationModulePath
    )

    Get-IncludeFile | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath

    Get-IncludeSystemFiles | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath

} Export-ModuleMember -Function Sync-IncludeWithModule