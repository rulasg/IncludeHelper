
function Test_ImportDepepency_Already_loaded{

    $name = "TargetModule" ; $modulesFolder = "ModulesFolder"
    Reset-InvokeCommandMock
    New-moduleV3 -Name $name -Path $modulesFolder


    # Mcok Get-Module present
    Mock_GetModule -Name $name -Folder $modulesFolder

    # Mock Import-Module
    Mock_ImportModule -Name $name -Folder $modulesFolder
    
    #Act
    $result = Import-Dependency -Name $name -Verbose -Confirm:$false 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from own module" 
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSCustomObject"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}

function Test_ImportDepepency_SideBySide{

    $name = "TargetModule" ; $modulesFolder = "ModulesFolder"
    Reset-InvokeCommandMock

    # Create new module on test folder
    New-moduleV3 -Name $name -Path $modulesFolder

    # Mock Get-Module to Null
    MockCallToNull -Command "Get-Module -Name $name"

    # Mock GetMyModuleRootPath on SideBySide
    Mock_GetMyModuleRootPath -Name "MeModule" -Folder $modulesFolder

    # Mock Import-Module
    Mock_ImportModule -Name $name -Folder $modulesFolder

    # Act
    $result = Import-Dependency -Name $name -Verbose -Confirm:$false 4>&1  # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from side by side path"
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSCustomObject"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}

function Test_ImportDepepency_Import_From_Module_Manager{

    $name = "TargetModule" ; $modulesFolder = "ModulesFolder"

    Reset-InvokeCommandMock

    New-ModuleV3 -Name $name -Path $modulesFolder

    # Mock Get-Module to Null
    Mock_GetModule_Null -Name $name

    # Mock GetMyModuleRootPath on SideBySide
    Mock_GetMyModuleRootPath -Name "MeModule" -Folder "MeFolderRoot"

    # Mock Get-Module -ListAvailable
    Mock_GetModuleListAvailable -Name $name -Folder $modulesFolder

    # Mock Import-Module
    Mock_ImportModule -Name $name -Folder $modulesFolder


    #Act
    $result = Import-Dependency -Name $name -Verbose -Confirm:$false 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from Powershell Module Manager"
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSCustomObject"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}

function Test_ImportDepepency_Install_From_Gallery{

    $name = "TargetModule" ; $modulesFolder = "ModulesFolder"
    Reset-InvokeCommandMock
    New-ModuleV3 -Name $name -Path $modulesFolder

    # Mock Get-Module to Null
    Mock_GetModule_Null -Name $name
    # Mock GetMyModuleRootPath on SideBySide
    Mock_GetMyModuleRootPath -Name "MeModule" -Folder "MeFolderRoot"
    # Mock Get-Module -ListAvailable
    Mock_GetModuleListAvailable_null -Name $name
    # # Mock Test repo in github
    # Mock_TestGitHubRepo -Owner $owner -Name $name

    # Mock FindModule
    MockCallExpression -Command "Find-Module -Name $name -AllowPrerelease -ErrorAction SilentlyContinue" -Expression "New-Object -TypeName PSCustomObject -Property @{ Name = '$name'}"

    #InstallModule
    $expression=@'
    Set-InvokeCommandAlias -Alias '{alias}' -Command '{command}' -Tag '{tag}'
    return $null
'@
    $expression = $expression -replace "{alias}", "Get-Module -Name $name -ListAvailable"
    $expression = $expression -replace "{command}", 'New-Object -TypeName PSCustomObject -Property @{ Name = "$name" }'
    $expression = $expression -replace "{tag}", $MODULE_INVOKATION_TAG_MOCK
    MockCallExpression -Command "Install-Module -Name $name -AllowPrerelease -Force" -Expression $expression

    #Act
    $result = Import-Dependency -Name $name -Verbose -Confirm:$false 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] installed from PowerShell Gallery"
}

function Test_ImportDependency_Clone_From_GitHub{

    $name = "TargetModule" ; $modulesFolder = "ModulesFolder"
    $owner = "rulasg"
    Reset-InvokeCommandMock

    # Mock Get-Module to Null
    Mock_GetModule_Null -Name $name
    # Mock GetMyModuleRootPath on SideBySide
    Mock_GetMyModuleRootPath -Name "MeModule" -Folder $modulesFolder
    # Mock Get-Module -ListAvailable
    Mock_GetModuleListAvailable_null -Name $name
    # Mock Test repo in github
    Mock_TestGitHubRepo -Owner $owner -Name $name
    # Mock FindModule
    MockCallToNull -Command "Find-Module -Name $name -AllowPrerelease -ErrorAction SilentlyContinue"

    # Mock clone repo
    Mock_CloneRepo -Owner $owner -Name $name -Folder $modulesFolder

    # Mock Import-Module
    Mock_ImportModule -Name $name -Folder $modulesFolder


    $result = Import-Dependency -Name $name -Verbose -Confirm:$false 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] cloned from GitHub repository"
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from GitHub repository"
}


function Mock_GetModule{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name,
        [Parameter(Mandatory,Position=1)][string]$Folder
    )
    $path = "$Folder/$Name"
    $path = Convert-Path -Path $path
    $expression = "New-Object -TypeName PSCustomObject -Property @{ Name = '$name'; Path = '$path' }"

    MockCallExpression -Command "Get-Module -Name $name" -Expression $expression
}

function Mock_GetModule_Null{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name
    )
    
    MockCallToNull -Command "Get-Module -Name $name"
}


function Mock_GetModuleListAvailable{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name,
        [Parameter(Mandatory,Position=1)][string]$Folder
    )
    
    $path = "$Folder/$Name"
    $path = Convert-Path -Path $path
    $expression = "New-Object -TypeName PSCustomObject -Property @{ Name = '$name'; Path = '$path' }"
    
    MockCallExpression -Command "Get-Module -Name $name -ListAvailable" -Expression $expression
}

function Mock_GetModuleListAvailable_Null{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name
    )
    
    MockCallToNull -Command "Get-Module -Name $name -ListAvailable" 
}


function Mock_ImportModule{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name,
        [Parameter(Mandatory,Position=1)][string]$Folder
    )

    # On Import-Module we need to mock update Get-Module to return the module
    $expression = @'
    # Overrite the Get-Module Mock
    Set-InvokeCommandAlias -Alias 'Get-Module -Name {name}' -Command '{command}' -Tag '{tag}'

    # return an object with name
    New-Object -TypeName PSCustomObject -Property @{ Name = '{name}' }
'@
    $expression = $expression -replace "{alias}", 'Import-Module -Name {name} -Scope Global -Verbose:$false -PassThru'
    $expression = $expression -replace "{command}", 'New-Object -TypeName PSCustomObject -Property @{ Name = "{name}" }'
    $expression = $expression -replace "{tag}", $MODULE_INVOKATION_TAG_MOCK
    $expression = $expression -replace "{name}", $name

    $path = "$Folder/$Name"
    $path = Convert-MyPath -Path $path
    $command = 'Import-Module -Name {path} -Scope Global -Verbose:$false -PassThru'
    $command = $command -replace "{path}", $path

    MockCallExpression -Command $command -Expression $expression
    
}

function Convert-MyPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Path
    )

    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        $created=$true
    }
    # Convert-Path -Path $path
    $path = Convert-Path -Path $path

    if ($created) {
        # Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        $null = Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }

    return $path
}

function Mock_GetMyModuleRootPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=1)][string]$Name,
        [Parameter(Mandatory,Position=2)][string]$Folder
    )

    # Mock GetMyModuleRootPath on SideBySide
    # Check that happens before ImportFromModuleManager 
    # that we are testing here
    $modulePath = "$Folder/$Name" 
    New-ModuleV3 -Name $Name -Path $folder
    $path = Convert-Path -Path $modulePath
    MockCallToString -Command 'GetMyModuleRootPath' -OutString "$path"
}

# Set-MyInvokeCommandAlias -Alias "TestGitHubRepo" -Command 'Invoke-WebRequest -Uri "{url}" -Method Head -ErrorAction SilentlyContinue | ForEach-Object { $_.StatusCode -eq 200 }'
function Mock_TestGitHubRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Owner,
        [Parameter(Mandatory,Position=1)][string]$Name
    )

    $url = "https://github.com/$owner/$name"

    $command = 'Invoke-WebRequest -Uri "{url}" -Method Head -ErrorAction SilentlyContinue | ForEach-Object { $_.StatusCode -eq 200 }'
    $command = $command -replace "{url}", $Url

    MockCallExpression -Command $command -Expression 'return $true'
}

function Mock_CloneRepo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Owner,
        [Parameter(Mandatory,Position=1)][string]$Name,
        [Parameter(Mandatory,Position=2)][string]$Folder
    )
    
    $url = "https://github.com/$owner/$Name"
    $path = "$Folder/$Name"
    $path = Convert-MyPath -Path $path

    $command = 'git clone {url} {path}'
    $command = $command -replace "{url}", $Url
    $command = $command -replace "{path}", $Path

    $expression = @'
        New-Modulev3 -Name '{name}' -Path '{folder}'
        return $null
'@
    $expression = $expression -replace "{name}", $Name
    $expression = $expression -replace "{folder}", $Folder

    MockCallExpression -Command $command -Expression $expression

}