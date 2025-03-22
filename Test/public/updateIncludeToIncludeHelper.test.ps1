function Test_UpdateIncludeToIncludeHelper{

    Mock_
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule

    New-TestingFile -Name MyInclude.ps1 -Path TestModule/Include
    New-TestingFile -Name MyHelper.ps1 -Path TestModule/Helper

    $includes = Get-IncludeFile -FolderName Include -ModuleRootPath TestModule

    Assert-NotImplemented
}