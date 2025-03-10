function Add-IncludeToWorkspace {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)][ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot')][string]$FolderName,
        [Parameter()][string]$DestinationModulePath = "."
    )

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

} Export-ModuleMember -Function Add-IncludeToWorkspace