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