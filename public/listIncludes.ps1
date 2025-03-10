<#
.SYNOPSIS
Displays the available includes.

.DESCRIPTION
This function retrieves and displays the available includes. It is useful for understanding what includes are available in the current context.

#>
function Get-IncludeFile{
    [CmdletBinding()]
    param(
        #add filter pattern
        [Parameter(Mandatory = $false, Position = 0)] [string]$Filter = '*'
    )

    $ret =@()

    $include = Get-ModuleFolder -FolderName 'Include'
    $includeTest = Get-ModuleFolder -FolderName 'TestInclude'

    $includeItems = Get-ChildItem -Path $include -Filter "*$Filter*" | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            FolderName = 'Include'
        }
    }
    if ($includeItems.Count -ne 0) {
        $ret += $includeItems
    }

    $includeTestItems = Get-ChildItem -Path $includeTest -Filter "*$Filter*" | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            FolderName = 'TestInclude'
        }
    }
    if ($includeTestItems.Count -ne 0) {
        $ret += $includeTestItems
    }

    return $ret
} Export-ModuleMember -Function Get-Includefiles

<#
.SYNOPSIS
Opens a specified include file in the default application.
.DESCRIPTION
This function opens a specified include file in the default application based on the operating system. It supports Windows, macOS, and Linux.
.PARAMETER Name
The name of the include file to open. This parameter is mandatory and accepts a string.
.PARAMETER FolderName
The name of the folder where the include file is located. This parameter is mandatory and accepts a string from a predefined set of values: 'Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot'.
.EXAMPLE
Open-IncludeFile -Name "MyInclude.ps1" -FolderName "Include"
Open-IncludeFile -Name "TestInclude.txt" -FolderName "TestInclude"
#>
function Open-IncludeFile{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)][string]$Name,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName, Position = 1)][ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot')][string]$FolderName
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
