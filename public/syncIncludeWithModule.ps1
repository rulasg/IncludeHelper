function Sync-IncludeWithModule{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][ValidateSet("All","File","System")][string]$FileType ="All",
        [Parameter()][string]$DestinationModulePath,
        [Parameter()][switch]$DestinationIncludeHelper,
        [Parameter()][switch]$SourceLocal
    )

    $local = $SourceLocal.IsPresent

    if($FileType -eq "File" -or $FileType -eq "All"){
        Get-IncludeFile -Local:$local        | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath -SourceLocal:$SourceLocal -DestinationIncludeHelper:$DestinationIncludeHelper
    }
    if($FileType -eq "System" -or $FileType -eq "All"){
        Get-IncludeSystemFiles -Local:$local | Add-IncludeToWorkspace -IfExists -DestinationModulePath $DestinationModulePath -SourceLocal:$SourceLocal -DestinationIncludeHelper:$DestinationIncludeHelper
    }

} Export-ModuleMember -Function Sync-IncludeWithModule