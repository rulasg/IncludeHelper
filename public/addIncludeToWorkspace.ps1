<#
.SYNOPSIS
Adds an include folder to the workspace.

.DESCRIPTION
The Add-IncludeToWorkspace function adds a specified include folder to the workspace. 
It supports ShouldProcess for safety and allows specifying the destination module path.

.PARAMETER Name
The name of the include to add. This parameter is mandatory and accepts a string.

.PARAMETER FolderName
The name of the folder to add. This parameter is mandatory and accepts a string from a predefined set of values: 'Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot','Tools'.

.PARAMETER DestinationModulePath
The path to the destination module. This parameter is optional and defaults to the current directory (".").

.EXAMPLE
Add-IncludeToWorkspace -Name "MyInclude.ps1" -FolderName "Include" -DestinationModulePath "C:\MyModule"

.EXAMPLE
Add-IncludeToWorkspace -Name "TestInclude.txt" -FolderName "TestInclude"
#>
function Add-IncludeToWorkspace {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)]
        [ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')]
        [string]$FolderName,
        [Parameter()][string]$DestinationModulePath = "."
    )

    process{

        $sourceIncludeModuleFolder = Get-ModuleFolder -FolderName $FolderName
        "Source folder is $sourceIncludeModuleFolder" | Write-Verbose
        $destinationpath = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $DestinationModulePath
        "Destination folder is $destinationpath" | Write-Verbose
        
        $sourceFile = $sourceIncludeModuleFolder | Join-Path -ChildPath $Name
        "Source file is $sourceFile" | Write-Verbose
        $destinationFile = $destinationpath | Join-Path -ChildPath $Name
        "Destination file is $destinationFile" | Write-Verbose
        
        # Check if there is a .psd1 file in the DestinationModulePath
        $psd1File = Get-ChildItem -Path $DestinationModulePath -Filter *.psd1 -ErrorAction SilentlyContinue
        if (-Not $psd1File) {
            throw "Destination Path $DestinationModulePath does not seem to be a PowershellMddule."
        }
        
        # create destination folder if it does not exist
        if(-Not (Test-Path $destinationpath)){
            $null = New-Item -Path $destinationpath -ItemType Directory -Force
        }
        
        # Check if source file exists
        if(-Not (Test-Path $sourceFile)){
            throw "File $sourceFile not found"
        }
        
        if ($PSCmdlet.ShouldProcess("$sourceFile", "copy to $destinationFile")) {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        }
    }

} Export-ModuleMember -Function Add-IncludeToWorkspace

function Copy-IncludeToWorkSpace{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Add relative path to the include file
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$FolderPath,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter()][string]$DestinationModulePath = "."
    )
    
    process{

        $includeRoot = Get-ModuleFolder -FolderName 'Root'

        $sourceIncludeModuleFolder = $includeRoot | Join-Path -ChildPath $FolderPath
        "Source folder is $sourceIncludeModuleFolder" | Write-Verbose
        $destinationpath = $DestinationModulePath | Join-Path -ChildPath $FolderPath
        "Destination folder is $destinationpath" | Write-Verbose
        
        $sourceFile = $sourceIncludeModuleFolder | Join-Path -ChildPath $Name
        "Source file is $sourceFile" | Write-Verbose
        $destinationFile = $destinationpath | Join-Path -ChildPath $Name
        "Destination file is $destinationFile" | Write-Verbose
        
        # Check if there is a .psd1 file in the DestinationModulePath
        $psd1File = Get-ChildItem -Path $DestinationModulePath -Filter *.psd1 -ErrorAction SilentlyContinue
        if (-Not $psd1File) {
            throw "Destination Path $DestinationModulePath does not seem to be a PowershellMddule."
        }
        
        # create destination folder if it does not exist
        if(-Not (Test-Path $destinationpath)){
            $null = New-Item -Path $destinationpath -ItemType Directory -Force
        }
        
        # Check if source file exists
        if(-Not (Test-Path $sourceFile)){
            throw "File $sourceFile not found"
        }
        
        if ($PSCmdlet.ShouldProcess("$sourceFile", "copy to $destinationFile")) {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        }
    }

} Export-ModuleMember -Function Copy-IncludeToWorkSpace