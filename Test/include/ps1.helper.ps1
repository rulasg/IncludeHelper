# PS1 HELPER
#
# Helper functions to manage the PS1 module files.
#
# THIS INCLUDE FILE REQURED module.helper.ps1
if(-not $MODULE_ROOT_PATH){ throw "Missing MODULE_ROOT_PATH varaible initialization. Check for module.helerp.ps1 file." }

$VALID_FOLDER_NAMES = @('Include', 'Private', 'Public', 'Root', 'TestInclude', 'TestPrivate', 'TestPublic', 'TestRoot', 'Tools', 'DevContainer', 'WorkFlows', 'GitHub', 'Helper', 'Config', 'TestHelper', 'TestConfig')

class ValidFolderNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
	  return $script:VALID_FOLDER_NAMES
    }
}

function Get-Ps1FullPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 0)][string]$Name,
        [Parameter(Position = 1)][ValidateSet([ValidFolderNames])][string]$FolderName,
        [Parameter(Position = 0)][string]$ModuleRootPath
    )

   # If folderName is not empty
    if($FolderName -ne $null){
        $folder = Get-ModuleFolder -FolderName $FolderName -ModuleRootPath $ModuleRootPath
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

# function Test-ModuleFolderName{
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory,Position = 0)]
#         [ValidateSet([ValidFolderNames])]
#         [string]$FolderName
#     )

#     return $true
# }

function Get-ModuleFolder{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position = 1)]
        [ValidateSet([ValidFolderNames])]
        [string]$FolderName,
        [Parameter(Position = 0)][string]$ModuleRootPath
    )

    # if ModuleRootPath is not provided, default to local module path
    if([string]::IsNullOrWhiteSpace($ModuleRootPath)){
        $ModuleRootPath = $MODULE_ROOT_PATH
    }

    # Convert to full path
    $ModuleRootPath = Convert-Path -Path $ModuleRootPath

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