function Test_GetModuleFolder{

    # Not calling Get-ModuleFolder before loading the module to avoid confiusion. Smae function name from different ps1, test include or main include.
    $moduleRootPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    
    # Load include file to test
    . $(Get-Ps1FullPath -Name "ps1.helper.ps1" -FolderName "Include")

    $result = Get-ModuleFolder -FolderName "Public"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "public") -Presented $result

    $result = Get-ModuleFolder -FolderName "Private"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "private") -Presented $result

    $result = Get-ModuleFolder -FolderName "Include"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "include") -Presented $result

    $result = Get-ModuleFolder -FolderName "TestInclude"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "Test\include") -Presented $result

    $result = Get-ModuleFolder -FolderName "TestPrivate"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "Test\private") -Presented $result

    $result = Get-ModuleFolder -FolderName "TestPublic"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "Test\public") -Presented $result

    $result = Get-ModuleFolder -FolderName "Root"

    Assert-AreEqual -Expected $moduleRootPath -Presented $result

    $result = Get-ModuleFolder -FolderName "TestRoot"

    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "Test") -Presented $result

    $result = Get-ModuleFolder -FolderName "Tools"
    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath "tools") -Presented $result

    $result = Get-ModuleFolder -FolderName "DevContainer"
    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath ".devcontainer") -Presented $result

    $result = Get-ModuleFolder -FolderName "WorkFlows"
    Assert-AreEqual -Expected ($moduleRootPath | Join-Path -ChildPath ".github/workflows") -Presented $result
}