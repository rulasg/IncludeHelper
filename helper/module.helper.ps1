# Helper for module variables

$MODULE_ROOT_PATH = $PSScriptRoot | Split-Path -Parent 
$MODULE_NAME = (Get-ChildItem -Path $moduleRootPath -Filter *.psd1 | Select-Object -First 1).BaseName