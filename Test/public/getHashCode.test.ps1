function Test_GetHashCode{

    # Load include file to test
    . $(Get-Ps1FullPath -Name getHashCode.ps1 -FolderName "Include" -ModuleRootPath $MODULE_ROOT_PATH)

    $result = Get-HashCode -InputString "test"

    Assert-AreEqual -Expected "098F6BCD4621D373CADE4E832627B4F6" -Presented $result
}