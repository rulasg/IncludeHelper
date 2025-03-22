
function Test_Ps1Helper_AreEqual_InModule_And_TestModule{
    
    # to avoid confusion we need to ensure that this helper has the same 
    # code in both module and test modules

    $name = "ps1.helper.ps1"
    
    $files = get-includefile -Filter $name

    $filePath = @{}

    0,1 | ForEach-Object{
        $path = Get-ModuleFolder -FolderName $files[$_].FolderName -ModuleRootPath $MODULE_ROOT_PATH
        $filePath[$_]= $path | Join-Path -ChildPath $files[$_].Name
    }

    $content1 = Get-Content -Path $filePath[0] | Out-String
    $content2 = Get-Content -Path $filePath[1] | Out-String

    Assert-AreEqual -Expected $content1 -Presented $content2

}

function Test_GetModuleFolder{

    # Load include file to test
    . $(Get-Ps1FullPath -Name "ps1.helper.ps1" -FolderName "Include" -ModuleRootPath $MODULE_ROOT_PATH)

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