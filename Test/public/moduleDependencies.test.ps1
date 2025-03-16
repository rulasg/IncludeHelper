
function Test_ImportDepepency_Already_loaded{

    $modulesFolder= "dummyfolder" ; $name = "TargetModule" 
    Reset-ImportModuleEnvironment -Name $name
    New-ModuleV3 -Name $name -Path $modulesFolder
    
    #Arrange - load module
    $modulepath = "$modulesFolder/$name" | Convert-Path
    Import-Module -Name $modulepath -Scope Global

    #Act
    $result = Import-Dependency -Name $name -Verbose 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from own module" 
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSModuleInfo"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}

function Test_ImportDepepency_SideBySide{

    $modulesFolder= "dummyfolder" ; $name = "TargetModule"
    Reset-ImportModuleEnvironment -Name $name
    New-ModuleV3 -Name $name -Path $modulesFolder

    #Arrange - create side by side
    $meName = "MyModule"
    $mePath = "$modulesFolder/$meName" 
    New-ModuleV3 -Name $meName -Path $modulesFolder
    $convertedMePath = Convert-Path -Path $mePath
    MockCallToString -Command 'GetMyModuleRootPath' -OutString "$convertedMePath"


    # Act
    $result = Import-Dependency -Name $name -Verbose 4>&1  # pipe verbose stream to standard output

    #Assert verbose message
    Assert-IsNotNull -Object $result
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from side by side path"
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSModuleInfo"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}

function Test_ImportDepepency_Import_From_Module_Manager{

    $modulesFolder= "dummyfolder" ; $name = "TargetModule" 
    $modulepath = "$modulesFolder/$name"
    Reset-ImportModuleEnvironment -Name $name
    New-ModuleV3 -Name $name -Path $modulesFolder

    # Arrange Mock GetMyModuleRootPath on SideBySide
    # Check that happens before ImportFromModuleManager 
    # that we are testing here
    $meModuleFolder = "dummyfolder2"
    $meName = "MyModule"
    $mePath = "$meModuleFolder/$meName" 
    New-ModuleV3 -Name $meName -Path $meModuleFolder
    $convertedMePath = Convert-Path -Path $mePath
    MockCallToString -Command 'GetMyModuleRootPath' -OutString "$convertedMePath"

    #Arrange - load module
    AddLocalToPsModulePath -Path $modulepath

    #Act
    $result = Import-Dependency -Name $name -Verbose 4>&1 # pipe verbose stream to standard output

    #Assert verbose message
    $modulePath = $result[2].Path
    Assert-AreEqual -Presented $result[0] -Expected "Loading module from path '$modulepath'."
    Assert-Contains -Presented $result -Expected "Module [$Name] imported from Powershell Module Manager"
    # Assert module output
    $module = $result | where-object {$_.GetType().Name -eq "PSModuleInfo"}
    Assert-AreEqual -Expected $name -Presented $module.Name
}


function Reset-ImportModuleEnvironment{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name
    )

    # reset all testing mocks
    Reset-InvokeCommandMock

    # Unload module from memory
    Remove-Module -Name $Name -Force -ErrorAction SilentlyContinue

}

function MockCall_GetMyModuleRootPath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Path
    )

    # Mock the module root path
    $mockmoduleroot= Convert-Path -Path $modulePath

    # return the root path for some test Arranges
    return $modulePath
}

function CreateSideBySideModule{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Name
    )

    $modulesFolder= "dummyfolder"

    # Create new module on test folder
    $modulePath = "$modulesFolder/$Name"
    New-ModuleV3 -Name $Name -Path $modulePath

    return $modulePath

}

function AddLocalToPsModulePath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )
    
    $splitchar = ($IsWindows) ? ';' : ':'
    
    $localPath = Convert-Path -Path $Path
    
    $env:PSModulePath += ("$splitChar{0}" -f ( Resolve-Path -Path $localPath ))
}