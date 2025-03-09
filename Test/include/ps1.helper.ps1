
function Import-Ps1Public{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Name,
        [Parameter(Mandatory,Position = 1)]
        [ValidateSet('Public', 'Private', 'Include', 'TestInclude','TestPrivate', 'TestPublic')]
        [string]$FolderName
    )
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