
function Test_GetModuleFolder{

    $local = $PSScriptRoot
    $moduleRootPath = $local | Split-Path -Parent | Split-Path -Parent

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
}