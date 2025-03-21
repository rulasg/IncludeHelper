function Get-Ps1FullPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Name,
        [Parameter(Position = 1)]
        [ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')]
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
        [ValidateSet('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')]
        [string]$FolderName,
        [Parameter(Position = 0)][string]$ModuleRootPath
    )

    #checkif $moduleRootPath is null,  whitespace or empty
    if([string]::IsNullOrWhiteSpace($ModuleRootPath)){
        $ModuleRootPath = $PSScriptRoot | Split-Path -Parent
    }

    # TestRootPath
    $testRootPath = $ModuleRootPath | Join-Path -ChildPath "Test"

    switch ($FolderName){
        'Public'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "public"
        }
        'Private'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "private"
        }
        'Include'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "include"
        }
        'TestInclude'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "include"
        }
        'TestPrivate'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "private"
        }
        'TestPublic'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "public"
        }
        'Root'{
            $moduleFolder = $ModuleRootPath
        }
        'TestRoot'{
            $moduleFolder = $testRootPath
        }
        'Tools'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "tools"
        }
        'DevContainer'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".devcontainer"
        }
        'WorkFlows'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".github/workflows"
        }
        'GitHub'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath ".github"
        }
        'Helper'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "helper"
        }
        'Config'{
            $moduleFolder = $ModuleRootPath | Join-Path -ChildPath "config"
        }
        'TestHelper'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "helper"
        }
        'TestConfig'{
            $moduleFolder = $testRootPath | Join-Path -ChildPath "config"
        }
        default{
            throw "Folder [$FolderName] is unknown"
        }
    }
    return $moduleFolder
} Export-ModuleMember -Function Get-ModuleFolder