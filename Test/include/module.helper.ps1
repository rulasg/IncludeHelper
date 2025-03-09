function Get-TestedModuleName{
    [CmdletBinding()]
    param()

    $local = $PSScriptRoot
    $moduleRootPath = $local | Split-Path -Parent | Split-Path -Parent

    $moduleName = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName

    return $moduleName

}