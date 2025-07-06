function Test_AddIncludeToWorkspace{
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path

    ## Test for TestInclude
    $name = "invokeCommand.mock.ps1"
    $folderName = "TestInclude"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path
}

function Test_AddIncludeToWorkspace_Force{
    Import-Module -Name TestingHelper
    New-TestingFolder -Name TestModule

    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath -Force

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path

    ## Test for TestInclude
    $name = "invokeCommand.mock.ps1"
    $folderName = "TestInclude"
    $destinationModulePath = "TestModule"

    #Act
    Add-IncludeToWorkspace -Name $name -FolderName $folderName -DestinationModulePath $destinationModulePath -Force

    #Assert
    $folderNamePath = get-Modulefolder -FolderName $folderName -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath $name
    Assert-ItemExist -path $path
}

function Test_AddIncludeToWorkspace_WithFileTransformation{
    
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    $fileInfo = Get-IncludeSystemFiles -Filter '{modulename}' | Select-Object -First 1
    $destinationName = $fileInfo.Name -replace '{modulename}', 'TestModule'
    $destinationPath = Get-ModuleFolder -FolderName $fileInfo.FolderName -ModuleRootPath "TestModule"
    $destinationFilePath = $destinationPath | Join-Path -ChildPath $destinationName

    # Act
    $fileInfo | Add-IncludeToWorkspace -DestinationModulePath "TestModule"

    # Assert
    Assert-ItemExist -path $destinationFilePath
}

function Test_AddIncludeToWorkspace_IfExists{

    $moduleName = "TestModule"
    Import-Module -Name TestingHelper

    # Test for Include
    $includefiles = Get-IncludeFile
    $include1 = $includefiles | Where-Object { $_.FolderName -eq "github" } | Select-Object -First 1
    $include2 = $includefiles | Where-Object { $_.FolderName -eq "Include" } | Select-Object -First 1

    New-ModuleV3 -Name $moduleName
    $destFolder1 = get-Modulefolder -FolderName $include1.FolderName -ModuleRootPath $moduleName
    $destFolder2 = get-Modulefolder -FolderName $include2.FolderName -ModuleRootPath $moduleName

    New-TestingFile -Name $include1.Name -Path $destFolder1 -Content "Test content for $($include1.Name)"
    New-TestingFile -Name $include2.Name -Path $destFolder2 -Content "Test content for $($include2.Name)"

    #Act
    $includefiles | Add-IncludeToWorkspace -DestinationModulePath $moduleName -IfExists

    #Assert
    $filesDest1 = Get-ChildItem -Path $destFolder1
    Assert-Count -Expected 1 -Presented $filesDest1
    $contentFile1 = Get-Content -Path $filesDest1.FullName | Out-String
    $sourceFile1  = Get-Content -Path $include1.Path | Out-String
    Assert-AreEqual -Expected $sourceFile1 -Presented $contentFile1

    $filesDest2 = Get-ChildItem -Path $destFolder2
    Assert-Count -Expected 1 -Presented $filesDest2
    $contentFile2 = Get-Content -Path $filesDest2.FullName | Out-String
    $sourceFile2  = Get-Content -Path $include2.Path | Out-String
    Assert-AreEqual -Expected $sourceFile2 -Presented $contentFile2
}

function Test_AddIncludeToWorkspace_PipeParameters{
    
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule
    
    # Test for Include
    $destinationModulePath = "TestModule"
    
    $includesToAdd = @(
        [PSCustomObject]@{ Name = "config.ps1"; FolderName = "Include" },
        [PSCustomObject]@{ Name = "config.mock.ps1"; FolderName = "TestInclude" }
    )

    #Act
    $includesToAdd | Add-IncludeToWorkspace -DestinationModulePath $destinationModulePath

    #Assert
    $folderNamePath = get-Modulefolder -FolderName "Include" -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath "config.ps1"
    Assert-ItemExist -path $path
    $folderNamePath = get-Modulefolder -FolderName "TestInclude" -ModuleRootPath $destinationModulePath
    $path = $folderNamePath | Join-Path -ChildPath "config.mock.ps1"
    Assert-ItemExist -path $path

}

function Test_AddIncludeToWorkspace_WithoutSource_WithoutDestination{
    
    Reset-InvokeCommandMock

    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    $fileInfo = Get-IncludeSystemFiles -Filter '{modulename}' | Select-Object -First 1
    $destinationName = $fileInfo.Name -replace '{modulename}', 'TestModule'
    $destinationPath = Get-ModuleFolder -FolderName $fileInfo.FolderName -ModuleRootPath "TestModule"
    $destinationFilePath = $destinationPath | Join-Path -ChildPath $destinationName
    Remove-Item -Path $destinationFilePath -ErrorAction SilentlyContinue

    
    # Act
    Assert-itemNotExist -path $destinationFilePath
    
    Set-Location -Path ./TestModule
    $fileInfo | Add-IncludeToWorkspace
    Set-Location -Path ../

    # Assert
    Assert-ItemExist -path $destinationFilePath
}

function Test_AddIncludeToWorkspace_FromSourceToDestination{

    Reset-InvokeCommandMock

    $TargetModuleName = "TargetModule"
    $SourceModuleName = "SourceModule"

    New-ModuleV3 -Name $TargetModuleName
    New-ModuleV3 -Name $SourceModuleName

    $TInclude = Get-ModuleFolder -FolderName Include -ModuleRootPath $TargetModuleName
    $SInclude = Get-ModuleFolder -FolderName Include -ModuleRootPath $SourceModuleName

    New-TestingFile -Name MyInclude1.ps1 -Path $SInclude
    New-TestingFile -Name MyInclude2.ps1 -Path $TInclude

    # Act
    $includes = Get-IncludeFile -ModuleRootPath $SourceModuleName -Filter *2
    $includes | Add-IncludeToWorkspace -SourceModulePath $SourceModuleName -DestinationModulePath $TargetModuleName

    # Assert
    Assert-ItemExist -Path "$TInclude\MyInclude2.ps1"
    Assert-ItemNotExist -Path "$TInclude\MyInclude1.ps1"

    # Act
    $includes = Get-IncludeFile -ModuleRootPath $SourceModuleName
    $includes | Add-IncludeToWorkspace -SourceModulePath $SourceModuleName -DestinationModulePath $TargetModuleName
    
        # Assert
    Assert-ItemExist -Path "$TInclude\MyInclude1.ps1"
    Assert-ItemExist -Path "$TInclude\MyInclude2.ps1"
}

# With soruce not destination
function Test_AddIncludeToWorkspace_FromSourceToDestination_WithoutDestination{
    
    Reset-InvokeCommandMock

    $FileName1 = "MyInclude1.ps1"
    $FileName2 = "MyInclude2.ps1"

    $DestinationModuleName = "DestinationModule"
    $SourceModuleName = "SourceModule" 

    $DestinationModulePath =  New-ModuleV3 -Name $DestinationModuleName
    $SourceModulePath =  New-ModuleV3 -Name $SourceModuleName

    $TInclude = Get-ModuleFolder -FolderName Include -ModuleRootPath $DestinationModulePath
    $SInclude = Get-ModuleFolder -FolderName Include -ModuleRootPath $SourceModulePath

    New-TestingFile -Name $FileName1 -Path $SInclude
    New-TestingFile -Name $FileName2 -Path $SInclude

    Set-Location -Path $DestinationModulePath

    # Act
    $includes = Get-IncludeFile -ModuleRootPath $SourceModulePath
    Assert-Count -Expected 2 -Presented $includes
    $includes | Add-IncludeToWorkspace -SourceModulePath $SourceModulePath
    
    # Assert
    Assert-ItemExist -Path "$TInclude\MyInclude1.ps1"
    Assert-ItemExist -Path "$TInclude\MyInclude2.ps1"
}

$moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
$targetPS1 = $moduleRootPath | Join-Path -ChildPath "public\addIncludeToWorkspace.ps1"
. $targetPS1

function Test_ResolveSourceDestinationPath{

    $DestinationModuleName = "TargetModule"
    $SourceModuleName = "SourceModule"
    $LocalModuleName = "LocalModule"

    $IncludeHelperModulePath = (Get-Module -name Includehelper).Path | Split-Path -parent

    New-ModuleV3 -Name $DestinationModuleName ; $DestinationModulePath = $DestinationModuleName | Convert-Path
    New-ModuleV3 -Name $SourceModuleName ; $SourceModulePath = $SourceModuleName | Convert-Path
    New-ModuleV3 -Name $LocalModuleName ; $LocalModulePath = $LocalModuleName | Convert-Path

    $LocalModuleName | Set-Location

    # Act Null / Null - Soruce:Include to Destination:local
    $resultsource,$resultdestination = Resolve-SourceDestinationPath
    Assert-AreEqualPath -Presented $resultsource -Expected $IncludeHelperModulePath
    Assert-AreEqualPath -Presented $resultdestination -Expected $LocalModulePath

    # Act Source / Null - Source: Path to Destination: local
    $resultsource,$resultdestination = Resolve-SourceDestinationPath -SourceModulePath $SourceModulePath
    Assert-AreEqualPath -Presented $resultsource -Expected $SourceModulePath
    Assert-AreEqualPath -Presented $resultdestination -Expected $LocalModulePath

    # Act Null / Destination sourceI:Include to Destination: Path
    $resultsource,$resultdestination = Resolve-SourceDestinationPath -DestinationModulePath $DestinationModulePath
    Assert-AreEqualPath -Presented $resultsource -Expected $IncludeHelperModulePath
    Assert-AreEqualPath -Presented $resultdestination -Expected $DestinationModulePath

    # Act Sorce / Destination - Source: Path to Destination: Path
    $resultsource,$resultdestination = Resolve-SourceDestinationPath -SourceModulePath $SourceModulePath -DestinationModulePath $DestinationModulePath
    Assert-AreEqualPath -Presented $resultsource -Expected $SourceModulePath
    Assert-AreEqualPath -Presented $resultdestination -Expected $DestinationModulePath

}

function Test_UpdateIncludeFileToIncludeHelper{

    Assert-SkipTest -Message "Interactive test. Run manually"

    # Arrange
    New-ModuleV3 -Name TestModule
    New-TestingFile -Name "MyInclude.ps1" -Path TestModule\Include
    $includes = Get-IncludeFile -ModuleRootPath TestModule -Filter "My*"

    # Act
    $includes | Update-IncludeFileToIncludeHelper -SourceModulePath "TestModule"

    #Assert
    $includeHelperPath = Get-ModuleFolder -FolderName Include
    Assert-ItemExist -Path "$includeHelperPath/MyInclude.ps1"

    # Ceanup
    Remove-Item -Path "$includeHelperPath/MyInclude.ps1"
    Assert-ItemNotExist -Path "$includeHelperPath/MyInclude.ps1"
}
