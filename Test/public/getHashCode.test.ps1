function Test_GetHashCode{

    # Load include file to test
    $moduleRootPath = $PsScriptRoot | Split-Path -Parent | Split-Path -Parent
    . $(Get-Ps1FullPath -Name getHashCode.ps1 -FolderName "Include" -ModuleRootPath $moduleRootPath)

    $result = Get-HashCode -InputString "test"

    Assert-AreEqual -Expected "098F6BCD4621D373CADE4E832627B4F6" -Presented $result
}