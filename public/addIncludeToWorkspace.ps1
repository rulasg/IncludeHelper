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

.PARAMETER SourceModulePath
The path to the source module. This parameter is optional and defaults to the IncludeHelper module.

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
        # [ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')]
        # [ValidateSet([ValidFolderNames])]
        [string]$FolderName,
        [Parameter()][string]$SourceModulePath,
        [Parameter()][string]$DestinationModulePath,
        [Parameter()][switch]$SourceLocal,
        [Parameter()][switch]$DestinationIncludeHelper,
        [Parameter()][switch]$IfExists
    )

    process{

        $SourceModulePath = $SourceLocal ? "." : $SourceModulePath
        $DestinationModulePath = $DestinationIncludeHelper ? (Get-ModuleFolder -FolderName 'Root') : $DestinationModulePath

        # Resolve source and destination module paths
        $SourceModulePath, $DestinationModulePath = Resolve-SourceDestinationPath -SourceModulePath $SourceModulePath -DestinationModulePath $DestinationModulePath

        # File paths
        # If source empty defaults to IncludeHelper
        $sourcePath = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $sourceModulePath
        "Source folder is $sourcePath" | Write-Verbose
        $destinationpath = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $DestinationModulePath
        "Destination folder is $destinationpath" | Write-Verbose

        # Expand file name trasnformation
        # Replace name {variables} with their value based on destination module
        $destinationName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $DestinationModulePath
        $souceName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $sourceModulePath

        # File Full paths
        $sourceFile = $sourcePath | Join-Path -ChildPath $souceName
        "Source file is $sourceFile" | Write-Verbose
        $destinationFile = $destinationpath | Join-Path -ChildPath $destinationName
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

        # Check for $IfExist switch
        if ($IfExists) {
            # Only copy if destination file exists
            # This is an upgrade functionality
            if (-Not (Test-Path $destinationFile)) {
                Write-Verbose "File $destinationFile does not exist and -IfExists was specified. Skipping."
                return
            } else {
                Write-Verbose "File $destinationFile exists and -IfExists was specified. Proceeding with copy."
            }
        }
        
        if ($PSCmdlet.ShouldProcess("$sourceFile", "copy to $destinationFile")) {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        }
    }

} Export-ModuleMember -Function Add-IncludeToWorkspace

function Resolve-SourceDestinationPath{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$SourceModulePath,
        [Parameter(Position=1)][string]$DestinationModulePath
    )
        # This function copies include files from one module to another
        # We have two wellknown modules: 
        #   1. Local Running module: this is the module where this function is running
        #   2. Local Path model : the module present where the location is set. aka '.'
        # We have two parameters:
        #   1. SourceModulePath: this is the module where the include file is copied from
        #   2. DestinationModulePath: this is the module where the include file is copied to
        # If SourceModulePath is not provided, default to IncludeHelper
        # If DestinationModulePath is not provided, default to current directory

        # If SourceModulePath is not provided, default to IncludeHelper
        if([string]::IsNullOrWhiteSpace($SourceModulePath)){
            $SourceModulePath = Get-ModuleFolder -FolderName 'Root' # IncludeHelper Root
        }

        # If DestinationModulePath is not provided, default to current directory
        if([string]::IsNullOrWhiteSpace($DestinationModulePath)){
            $DestinationModulePath = Get-ModuleFolder -FolderName 'Root' -ModuleRootPath '.'
        }
        
        $SourceModulePath = Convert-Path -Path $SourceModulePath
        $DestinationModulePath = Convert-Path -Path $DestinationModulePath

        return $SourceModulePath, $DestinationModulePath

}

function Expand-FileNameTransformation{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$FileName,
        [Parameter(Mandatory,ValueFromPipeline,Position=1)][string]$DestinationModulePath
    )

    begin{
        $moduleName = (Get-ChildItem -Path $DestinationModulePath -Filter *.psd1 | Select-Object -First 1).BaseName
        if(-Not $moduleName){
            # This should nevere happen as we should call with a proper DestinationModulePath
            throw "Module not found for Transformation at $DestinationModulePath"
        }
    }
    process{
        #ModuleName transformation
        $ret = $FileName -replace '{modulename}', $moduleName

        return $ret
    }
}

function Update-IncludeFileToIncludeHelper{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)][string]$FolderName,
        [Parameter()][string]$SourceModulePath
    )

    begin{
        # Destination always IncludeHelper
        $DestinationModulePath = Get-ModuleFolder -FolderName 'Root'

        $SourceModulePath = [string]::IsNullOrWhiteSpace($SourceModulePath) ? $(Get-ModuleFolder -FolderName 'Root' -ModuleRootPath '.') : $SourceModulePath
    }

    process{
        $params = @{
            Name = $Name
            FolderName = $FolderName
            SourceModulePath = $SourceModulePath
            DestinationModulePath = $DestinationModulePath
        }
        Add-IncludeToWorkspace @params
    }
}