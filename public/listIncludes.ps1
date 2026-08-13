<#
.SYNOPSIS
Displays the available includes.

.DESCRIPTION
    This function retrieves and displays the available includes. It is useful for understanding what includes are available in the current context.
.PARAMETER Filter
    The filter pattern to apply when retrieving includes. It is optional and defaults to '*', which retrieves all includes.
.PARAMETER ModuleRootPath
    The root path of the module. This parameter is optional and can be used to specify a different module root path if needed.
    If not specified, the function will use Local or IncludeHelper module root path.
.PARAMETER Local
    Specifies whether to use the local module root path. If this switch is set, the function will use the current directory as the module root path.
.EXAMPLE
    Get-IncludeFile
    List all include files available in IncludeHelper module to import to the workspace
.EXAMPLE
    Get-IncludeFile -Filter "MyInclude.ps1"
    List "MyInclude.ps1" include file if available in IncludeHelper module to import to the workspace
.EXAMPLE
    Get-IncludeFile -Local
    List all includes files localy on the workspace you are working on.
.EXAMPLE
    Get-IncludeFile -Filter "MyInclude.ps1" -Local
    List "MyInclude.ps1" include file if available in the workspace you are working on.
.EXAMPLE
    Get-IncludeFile -Filter "MyInclude.ps1" | Add-IncludeToWorkspace
    Copies "MyInclude.ps1" from IncludeHelper module to the workspace you are working on.
.EXAMPLE
    Get-IncludeFile -Filter "MyInclude.ps1" -Local | Update-IncludeToIncludeHelper
    Copies "MyInclude.ps1" from the workspace you are working on to IncludeHelper module.
#>
function Get-IncludeFile{
    [CmdletBinding()]
    [Alias("gif")]
    param(
        #add filter pattern
        [Parameter( Position = 0 )] [string]$Filter = '*',
        [Parameter()][string[]]$Folders,
        [Parameter()][switch]$Local,
        [Parameter()][string]$ModuleRootPath
    )

    #checkif $moduleRootPath is null,  whitespace or empty
    # If value keep value.
    # If Local use '.'
    # If not Localuse includeHelper module
    if([string]::IsNullOrWhiteSpace($ModuleRootPath)){
        $moduleRootPath = $Local ? "." : $(Get-ModuleRootPath)
    }

    $moduleName = Get-ModuleNameFromPath -Path $ModuleRootPath

    $ret =@()

    # If folder not specified search on default include folders
    $fileFolders = $Folders ?? @("Include","Helper","TestInclude","TestHelper")

    # Validate that all folder names are valid
    $invalidFolders = $folders | Where-Object { $_ -notin $VALID_FOLDER_NAMES }
    if ($invalidFolders.Count -gt 0) {
        Write-MyError "Invalid folder names: $($invalidFolders -join ', '). Valid names are: $($VALID_FOLDER_NAMES -join ', ')"
        return
    }

    $fileFolders| ForEach-Object {

        $FolderName = $_

        $path = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $ModuleRootPath

        $items = Get-ChildItem -Path $path -Filter "*$Filter*" -File  -ErrorAction SilentlyContinue | ForEach-Object {

            $content = Get-Content -Path $_.FullName
            $version = Get-VersionFromHeader -content $content
            if($version){
                $body = Remove-VersionHeader -content $content
            } else {
                $body = $content
            }

            $sha = $body -join "`n" | Get-HashCode
            $gitStatus = $(Test-RepoFileChanged -Path $_.FullName )? "Modified" : "Unmodified"

            [PSCustomObject]@{
                Name       = Compress-FileNameTransformation -FileName $_.Name -SourceModulePath $ModuleRootPath
                FolderName = $FolderName
                ModuleName = $moduleName
                Path       = $_.FullName
                Version    = $version.Version
                Date       = $version.Date
                Sha        = $sha
                GitStatus  = $gitStatus
            }
        }
        if ($items.Count -ne 0) {
            $ret += $items
        }
    }

    return $ret

} Export-ModuleMember -Function Get-IncludeFile -Alias "gif"

<#
.SYNOPSIS
Opens a specified include file in the default application.
.DESCRIPTION
This function opens a specified include file in the default application based on the operating system. It supports Windows, macOS, and Linux.
.PARAMETER Name
The name of the include file to open. This parameter is mandatory and accepts a string.
.PARAMETER FolderName
The name of the folder where the include file is located. This parameter is mandatory and accepts a string from a predefined set of values: 'Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot','Tools'.
.EXAMPLE
Open-IncludeFile -Name "MyInclude.ps1" -FolderName "Include"
Open-IncludeFile -Name "TestInclude.txt" -FolderName "TestInclude"
#>
function Open-IncludeFile{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)][string]$FolderName
    )

    process{

        $sourceIncludeModuleFolder = Get-ModuleFolder -FolderName $FolderName

        $sourceFile = $sourceIncludeModuleFolder | Join-Path -ChildPath $Name

        # Check if source file exists
        if(-Not (Test-Path $sourceFile)){
            throw "File $sourceFile not found"
        }

        # Open the file using the default application based on the OS
        if ($IsWindows) {
            Start-Process $sourceFile
        } elseif ($IsMacOS) {
            Start-Process "open" -ArgumentList $sourceFile
        } elseif ($IsLinux) {
            Start-Process "xdg-open" -ArgumentList $sourceFile
        } else {
            throw "Unsupported OS"
        }
    }

} Export-ModuleMember -Function Open-IncludeFile

function Compare-IncludeFile{
        [CmdletBinding()]
    [Alias("cif")]
    param(
        #add filter pattern
        [Parameter( Position = 0 )] [string]$Filter = '*',
        [Parameter()][string[]]$Folders,
        [Parameter()][string]$ModuleRootPath,
        [Parameter()][switch]$PassThru,
        [Parameter()][switch]$All,
        [Parameter()][switch]$Opendiff

    )

    # If not ModuleRootPath specified, use local
    if([string]::IsNullOrWhiteSpace($ModuleRootPath)){ $local = $true }

    $allLocal = Get-IncludeFile -Filter $Filter -Folders $Folders -ModuleRootPath:$ModuleRootPath -Local:$Local
    $allRemote = Get-IncludeFile -Filter $Filter -Folders $Folders -ModuleRootPath $ModuleRootPath

    $allLocal =$allLocal ?? @()
    $allRemote =$allRemote ?? @()
    
    "Found $($allLocal.Count) local and $($allRemote.Count) remote include files for filter [$Filter] in folders [$($Folders -join ', ')]" | Write-MyDebug -Section "cif"
    
    $ret = @()
    $done = @()

    # Compare existing files
    $allItems = $All ? $($allLocal + $allRemote) : $alllocal

    $allItems | ForEach-Object {
        # Check if done
        $filetag = "$($_.FolderName)_$($_.Name)"
        
        if($done -notcontains $filetag){ 
        
            $done += $filetag
            
            $local = $allLocal | Where-Object { "$($_.FolderName)_$($_.Name)" -eq $filetag }
            $remote = $allRemote | Where-Object { "$($_.FolderName)_$($_.Name)" -eq $filetag }
            "Local  : $($local.Name) $($local.FolderName) $($local.Version) $($local.Date) $($local.Sha) $($local.GitStatus)" | Write-MyDebug -Section "cif"
            "Remote : $($remote.Name) $($remote.FolderName) $($remote.Version) $($remote.Date) $($remote.Sha) $($remote.GitStatus)" | Write-MyDebug -Section "cif"

            $areEqual = $local.Sha -eq $remote.Sha
            
            $item = [PsCustomObject]@{
                Name = $_.Name
                FolderName = $_.FolderName
                
                AreEqual = $areEqual

                LocalVersion = $local.Version
                LocalDate = $local.Date
                LocalGitStatus = $local.GitStatus
                LocalPath = $local.Path
                
                RemoteVersion = $remote.Version
                RemoteDate = $remote.Date
                RemoteGitStatus = $remote.GitStatus
                RemotePath = $remote.Path
            }
            $ret += $item
        }
    }

    $ret = $ret |sort-object -Property AreEqual,FolderName, Name

    if($OpenDiff){
        $ret | foreach-object{
            if(-not $_.AreEqual){
                Write-MyDebug "Opening diff for $($_.Name) in folder $($_.FolderName)" -Section "cif"
                code --diff $($_.LocalPath) $($_.RemotePath)
            } else {
                Write-MyDebug "Skipping diff for $($_.Name) in folder $($_.FolderName) as they are equal" -Section "cif"
            }
        }
    }

    if($PassThru){
        return $ret
    } else {
        $ret | Format-Table -Property Name,FolderName,AreEqual,LocalVersion,LocalDate,LocalGitStatus,RemoteVersion,RemoteDate,RemoteGitStatus -AutoSize
    }
        
} Export-ModuleMember -Function Compare-IncludeFile -Alias "cif"
