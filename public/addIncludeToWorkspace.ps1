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
        [Parameter()][switch]$IfExists,
        [Parameter()][switch]$Force
    )

    begin{

        #">> Add-IncludeToWorkspace" | Write-MyDebug

        $SourceModulePath = $SourceLocal ? "." : $SourceModulePath
        $DestinationModulePath = $DestinationIncludeHelper ? (Get-ModuleFolder -FolderName 'Root') : $DestinationModulePath
        # Resolve source and destination module paths
        $SourceModulePath, $DestinationModulePath = Resolve-SourceDestinationPath -SourceModulePath $SourceModulePath -DestinationModulePath $DestinationModulePath

        #"SourceModulePath     : $SourceModulePath" | Write-MyDebug
        #"DestinationModulePath: $DestinationModulePath" | Write-MyDebug
    }

    process{

        # File paths
        # If source empty defaults to IncludeHelper
        $sourcePath = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $sourceModulePath
        ## "Source folder is $sourcePath" | Write-MyDebug
        $destinationpath = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $DestinationModulePath
        ## "Destination folder is $destinationpath" | Write-MyDebug

        # Expand file name trasnformation
        # Replace name {variables} with their value based on destination module
        $destinationName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $DestinationModulePath
        $souceName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $sourceModulePath

        # File Full paths
        $sourceFile = $sourcePath | Join-Path -ChildPath $souceName
        ## "Source file is $sourceFile" | Write-MyDebug
        $destinationFile = $destinationpath | Join-Path -ChildPath $destinationName
        ## "Destination file is $destinationFile" | Write-MyDebug

        # Check for $IfExist switch
        if ($IfExists) {
            # Only copy if destination file exists
            # This is an upgrade functionality
            if (-Not (Test-Path $destinationFile)) {
                #Write-MyDebug "SKIP : File does not exist and -IfExists was specified. Skipping $destinationFile"
                return
            }
        }

        #Write-MyDebug "COPY : $destinationFile"

        # Expand filecontent Transformations
        $content = Expand-FileContentTransformation -SourceFileName $sourceFile -SourceModulePath $SourceModulePath -DestinationModulePath $DestinationModulePath
        
        #Skip destination module check if Force is set
        if(-Not $Force){
            # Check if there is a .psd1 file in the DestinationModulePath
            $psd1File = Get-ChildItem -Path $DestinationModulePath -Filter *.psd1 -ErrorAction SilentlyContinue
            if (-Not $psd1File) {
                throw "Destination Path $DestinationModulePath does not seem to be a PowershellMddule."
            }
        }
        
        # create destination folder if it does not exist
        if(-Not (Test-Path $destinationpath)){
            #"Create folder $destinationpath" | Write-MyDebug
            $null = New-Item -Path $destinationpath -ItemType Directory -Force
        }
        
        # Check if source file exists
        if(-Not (Test-Path $sourceFile)){
            throw "File $sourceFile not found"
        }
        
        if ($PSCmdlet.ShouldProcess("$sourceFile", "copy to $destinationFile")) {
            # Copy-Item -Path $sourceFile -Destination $destinationFile -Force
            Set-Content -Path $destinationFile -Value $content -Force
            Write-Output $destinationFile
        }
    }

    end{
        #"<< Add-IncludeToWorkspace" | Write-MyDebug
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
        $moduleName = Get-ModuleNameFromPath -Path $DestinationModulePath
    }
    process{
        #ModuleName transformation
        $ret = $FileName -replace '{modulename}', $moduleName

        return $ret
    }
}

function Compress-FileNameTransformation{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$FileName,
        [Parameter(Mandatory,ValueFromPipeline,Position=1)][string]$SourceModulePath
    )

    begin{
        $moduleName = Get-ModuleNameFromPath -Path $SourceModulePath
    }
    process{
        #ModuleName transformation
        $ret = $FileName -replace $moduleName, '{modulename}'

        return $ret
    }
}

function Expand-FileContentTransformation{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline,Position=1)][string]$SourceFileName,
        [Parameter(Position=0)][string]$SourceModulePath,
        [Parameter(Position=2)][string]$DestinationModulePath
    )

    begin{
        $moduleName = Get-ModuleNameFromPath -Path $DestinationModulePath
    }
    process{
        $content = Get-Content -Path $SourceFileName -Raw

        # Trasnformation ModuleName
        $content = $content -replace '{modulename}', $moduleName

        return $content
    }
}

function Compress-FileNameTransformation{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$FileName,
        [Parameter(Mandatory,ValueFromPipeline,Position=1)][string]$SourceModulePath
    )

    begin{
        $moduleName = Get-ModuleNameFromPath -Path $SourceModulePath
    }
    process{
        #ModuleName transformation
        $ret = $FileName -replace $moduleName, '{modulename}'

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

function Get-ModuleNameFromPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$Path
    )

    process{
        # Get the module name from the path
        $moduleName = (Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1).BaseName
        if(-Not $moduleName){
            # Not a module folder. Figure out the module name from the path
            $moduleName = $Path | Split-Path -Leaf
            if(-Not $moduleName){
                # This should never happen as we should call with a proper Path
                throw "Unable to figure out Module Name from path $Path"
            }
        }
        return $moduleName
    }
}

function Get-ModuleGuidFromPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)][string]$Path
    )

    process{
        # Get the module guid from the path
        $psd1File = Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1
        if(-Not $psd1File){
            return $null
        }
        $moduleGuid = (Import-PowerShellDataFile -Path $psd1File.FullName).GUID
        return $moduleGuid
    }
}