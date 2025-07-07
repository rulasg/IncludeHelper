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
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)][string]$Name,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
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

    process {

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
        $souceName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $sourceModulePath
        $destinationName = Expand-FileNameTransformation -FileName $Name -DestinationModulePath $DestinationModulePath

        # File Full paths
        $sourceFile = $sourcePath | Join-Path -ChildPath $souceName
        "Source file is $sourceFile" | Write-Verbose
        $destinationFile = $destinationpath | Join-Path -ChildPath $destinationName
        "Destination file is $destinationFile" | Write-Verbose

        # Check for $IfExist switch
        if ($IfExists) {
            # Only copy if destination file exists
            # This is an upgrade functionality
            if (-Not (Test-Path $destinationFile)) {
                Write-Verbose "File $destinationFile does not exist and -IfExists was specified. Skipping."
                return
            }
            else {
                Write-Verbose "File $destinationFile exists and -IfExists was specified. Proceeding with copy."
            }
        }

        # Expand filecontent Transformations
        $param = [PSCustomObject]@{
            Name                  = $Name
            FolderName            = $FolderName
            SourceModulePath      = $SourceModulePath
            DestinationModulePath = $DestinationModulePath
            Content               = Get-Content -Path $sourceFile -Raw
        }

        $param = $param | Expand-FileContentTransformation_TestPsd1
        $param = $param | Expand-FileContentTransformation_ModuleName

        $content = $param.Content
        
        #Skip destination module check if Force is set
        if (-Not $Force) {
            # Check if there is a .psd1 file in the DestinationModulePath
            $psd1File = Get-ChildItem -Path $DestinationModulePath -Filter *.psd1 -ErrorAction SilentlyContinue
            if (-Not $psd1File) {
                throw "Destination Path $DestinationModulePath does not seem to be a PowershellMddule."
            }
        }
        
        # create destination folder if it does not exist
        if (-Not (Test-Path $destinationpath)) {
            $null = New-Item -Path $destinationpath -ItemType Directory -Force
        }
        
        # Check if source file exists
        if (-Not (Test-Path $sourceFile)) {
            throw "File $sourceFile not found"
        }
        
        if ($PSCmdlet.ShouldProcess("$sourceFile", "copy to $destinationFile")) {
            # Copy-Item -Path $sourceFile -Destination $destinationFile -Force
            Set-Content -Path $destinationFile -Value $content -Force
        }
    }

} Export-ModuleMember -Function Add-IncludeToWorkspace

function Resolve-SourceDestinationPath {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$SourceModulePath,
        [Parameter(Position = 1)][string]$DestinationModulePath
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
    if ([string]::IsNullOrWhiteSpace($SourceModulePath)) {
        $SourceModulePath = Get-ModuleFolder -FolderName 'Root' # IncludeHelper Root
    }

    # If DestinationModulePath is not provided, default to current directory
    if ([string]::IsNullOrWhiteSpace($DestinationModulePath)) {
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

function Update-IncludeFileToIncludeHelper{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)][string]$Name,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)][string]$FolderName,
        [Parameter()][string]$SourceModulePath
    )

    begin {
        # Destination always IncludeHelper
        $DestinationModulePath = Get-ModuleFolder -FolderName 'Root'

        $SourceModulePath = [string]::IsNullOrWhiteSpace($SourceModulePath) ? $(Get-ModuleFolder -FolderName 'Root' -ModuleRootPath '.') : $SourceModulePath
    }

    process {
        $params = @{
            Name                  = $Name
            FolderName            = $FolderName
            SourceModulePath      = $SourceModulePath
            DestinationModulePath = $DestinationModulePath
        }
        Add-IncludeToWorkspace @params
    }
}

function Get-ModuleNameFromPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Path
    )

    process {
        # Get the module name from the path
        $moduleName = (Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1).BaseName
        if (-Not $moduleName) {
            # Not a module folder. Figure out the module name from the path
            $moduleName = $Path | Split-Path -Leaf
            if (-Not $moduleName) {
                # This should never happen as we should call with a proper Path
                throw "Unable to figure out Module Name from path $Path"
            }
        }
        return $moduleName
    }
}

function Expand-FileNameTransformation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$FileName,
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)][string]$DestinationModulePath
    )

    begin {
        $moduleName = Get-ModuleNameFromPath -Path $DestinationModulePath
    }
    process {
        #ModuleName transformation
        $ret = $FileName -replace '{modulename}', $moduleName

        return $ret
    }
}

function Expand-FileContentTransformation_ModuleName {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)][string]$FolderName,
        [Parameter(ValueFromPipelineByPropertyName)][string]$SourceModulePath,
        [Parameter(ValueFromPipelineByPropertyName)][string]$DestinationModulePath,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Content

    )

    process {
        # Get ModuleName
        $moduleName = Get-ModuleNameFromPath -Path $DestinationModulePath
        
        # Trasnformation ModuleName
        $Content = $Content -replace '{modulename}', $moduleName

        return [PSCustomObject]@{
            Name                  = $Name
            FolderName            = $FolderName
            SourceModulePath      = $SourceModulePath
            DestinationModulePath = $DestinationModulePath
            Content               = $Content
        }

    }
}

function Expand-FileContentTransformation_TestPsd1 {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)][string]$FolderName,
        [Parameter(ValueFromPipelineByPropertyName)][string]$SourceModulePath,
        [Parameter(ValueFromPipelineByPropertyName)][string]$DestinationModulePath,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Content

    )

    process {

        # Check if the source file is a psd1 file
        if ($Name -eq "Test.psd1") {
            
            # Save content to file

            # Split the content into string array, one line per element
            $content = $Content -split '\r?\n'
            
            $destinationPath = Get-MouduleFilePath -Name $name -FolderName $FolderName -ModuleRootPath $DestinationModulePath
            $destinationManifest = Import-PowerShellDataFile -Path $destinationPath -ErrorAction SilentlyContinue

            # If destination path does not exist, return
            if (-Not (Test-Path $destinationPath)) {
                return
            }

            $destinationManifest = Import-PowerShellDataFile -Path $destinationPath

            # Replace all that we do not want to update from source to destination

            Copy-Psd1Field $content RootModule                 $destinationManifest.RootModule
            Copy-Psd1Field $content ModuleVersion              $destinationManifest.ModuleVersion
            ### Copy-Psd1Field $content CompatiblePSEditions   $destinationManifest.CompatiblePSEditions
            Copy-Psd1Field $content GUID                       $destinationManifest.GUID
            Copy-Psd1Field $content Author                     $destinationManifest.Author
            Copy-Psd1Field $content CompanyName                $destinationManifest.CompanyName
            Copy-Psd1Field $content Copyright                  $destinationManifest.Copyright
            Copy-Psd1Field $content Description                $destinationManifest.Description
            ### Copy-Psd1Field $content PowerShellVersion      $destinationManifest.PowerShellVersion
            ### Copy-Psd1Field $content PowerShellHostName     $destinationManifest.PowerShellHostName
            ### Copy-Psd1Field $content PowerShellHostVersion  $destinationManifest.PowerShellHostVersion
            ### Copy-Psd1Field $content DotNetFrameworkVersion $destinationManifest.DotNetFrameworkVersion
            ### Copy-Psd1Field $content ClrVersion             $destinationManifest.ClrVersion
            ### Copy-Psd1Field $content ProcessorArchitecture  $destinationManifest.ProcessorArchitecture
            ### Copy-Psd1Field $content RequiredModules        $destinationManifest.RequiredModules
            ### Copy-Psd1Field $content RequiredAssemblies     $destinationManifest.RequiredAssemblies
            ### Copy-Psd1Field $content ScriptsToProcess       $destinationManifest.ScriptsToProcess
            ### Copy-Psd1Field $content TypesToProcess         $destinationManifest.TypesToProcess
            ### Copy-Psd1Field $content FormatsToProcess       $destinationManifest.FormatsToProcess
            ### Copy-Psd1Field $content NestedModules          $destinationManifest.NestedModules
            
            # Copy-Psd1Field $content FunctionsToExport        $destinationManifest.FunctionsToExport
            # Copy-Psd1Field $content CmdletsToExport          $destinationManifest.CmdletsToExport
            # Copy-Psd1Field $content VariablesToExport        $destinationManifest.VariablesToExport
            # Copy-Psd1Field $content AliasesToExport          $destinationManifest.AliasesToExport

            ### Copy-Psd1Field $content DscResourcesToExport   $destinationManifest.DscResourcesToExport
            ### Copy-Psd1Field $content ModuleList             $destinationManifest.ModuleList
            ### Copy-Psd1Field $content FileList               $destinationManifest.FileList

            ## PrivateData.PSData
            ### Copy-Psd1Field $content Tags                   $destinationManifest.PrivateData.PSData.Tags
            ### Copy-Psd1Field $content LicenseUri             $destinationManifest.PrivateData.PSData.LicenseUri
            ### Copy-Psd1Field $content ProjectUri             $destinationManifest.PrivateData.PSData.ProjectUri
            ### Copy-Psd1Field $content IconUri                $destinationManifest.PrivateData.PSData.IconUri
            ### Copy-Psd1Field $content ReleaseNotes           $destinationManifest.PrivateData.PSData.ReleaseNotes
            Copy-Psd1Field $content Prerelease                 $destinationManifest.PrivateData.PSData.Prerelease
            ### Copy-Psd1Field $content RequireLicenseAcceptance   $destinationManifest.PrivateData.PSData.RequireLicenseAcceptance
            ### Copy-Psd1Field $content ExternalModuleDependencies $destinationManifest.PrivateData.PSData.ExternalModuleDependencies
            ### Copy-Psd1Field $content HelpInfoURI                $destinationManifest.PrivateData.PSData.HelpInfoURI
            ### Copy-Psd1Field $content DefaultCommandPrefix       $destinationManifest.PrivateData.PSData.DefaultCommandPrefix
        }

        return [PSCustomObject]@{
            Name                  = $Name
            FolderName            = $FolderName
            SourceModulePath      = $SourceModulePath
            DestinationModulePath = $DestinationModulePath
            Content               = $Content -join "`r`n" # Join the content back to a single string
        }
    }
}

function Copy-Psd1Field {
    [CmdletBinding()]
    param(
        #Content
        [Parameter(Mandatory, Position = 0)][array]$Content,
        #field
        [Parameter(Mandatory, Position = 1)][string]$Field,
        #Value
        [Parameter(Mandatory, Position = 2)][string]$Value
    )

    process {
        
        if($null -eq $Value) {
            # If value is null, remove the field
            return $content
        }
        
        foreach ($line in $Content) {
            # Check if the line contains the field
            if ($line -like "$Field *") {
                $newLine = "$Field = '$Value'"
                "[$line] => [$newLine] | Write-Host"
                # Replace the value of the field
                $content = $content -replace $line, $newLine
            }
        }

        return $content

    }
}


function Get-ModuleGuidFromPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)][string]$Path
    )

    process {
        # Get the module guid from the path
        $psd1File = Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1
        if (-Not $psd1File) {
            return $null
        }
        $moduleGuid = (Import-PowerShellDataFile -Path $psd1File.FullName).GUID
        return $moduleGuid
    }
}
