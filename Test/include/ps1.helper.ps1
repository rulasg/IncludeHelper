
function Get-Ps1FullPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Name,
        [Parameter(Position = 1)]
        [ValidateSet('Public', 'Private', 'Include', 'TestInclude','TestPrivate', 'TestPublic')]
        [string]$FolderName
    )

   # If folderName is not empty
    if($FolderName -ne $null){
        $folder = Get-ModuleFolder -FolderName $FolderName
        $path = $folder | Join-Path -ChildPath $Name
    } else {
        $path = $Name
    }

    # Check if file exists
    if(-Not (Test-Path $path)){
        throw "File $path not found"
    }

    # Get Path item
    $item = Get-item -Path $path

    return $item
}

function Get-ModuleFolder{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 1)]
        [ValidateSet('Public', 'Private', 'Include', 'TestInclude','TestPrivate', 'TestPublic')]
        [string]$FolderName
    )

    $local = $PSScriptRoot
    $moduleRootPath = $local | Split-Path -Parent | Split-Path -Parent

    switch ($FolderName){
        'Public'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "public"
        }
        'Private'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "private"
        }
        'Include'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "include"
        }
        'TestInclude'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "Test\include"
        }
        'TestPrivate'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "Test\private"
        }
        'TestPublic'{
            $moduleFolder = $moduleRootPath | Join-Path -ChildPath "Test\public"
        }
    }
    return $moduleFolder
}