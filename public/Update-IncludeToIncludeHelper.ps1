function Update-IncludeToIncludeHelper {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')]
        [string]$FolderName,
        [Parameter()][string]$DestinationModulePath = "."
    )

    begin {
        $includeRoot = Get-ModuleFolder -FolderName 'Include'
    }

    process{
        Add-IncludeToWorkspace -Name $Name -FolderName $FolderName -DestinationModulePath $includeRoot -WhatIf:$PSCmdlet.ShouldProcess("Adding $Name to workspace in folder $FolderName")
    }

}
