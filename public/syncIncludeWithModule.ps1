function Sync-IncludeWithModule{
    [CmdletBinding()]
    param(
        [Parameter()][string]$DestinationModulePath,
        [Parameter()][switch]$DestinationIncludeHelper,
        [Parameter()][switch]$SourceLocal
    )

    $local = $SourceLocal.IsPresent

    Get-IncludeFile -Local:$local        | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath -SourceLocal:$SourceLocal -DestinationIncludeHelper:$DestinationIncludeHelper

    Get-IncludeSystemFiles -Local:$local | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath -SourceLocal:$SourceLocal -DestinationIncludeHelper:$DestinationIncludeHelper

} Export-ModuleMember -Function Sync-IncludeWithModule