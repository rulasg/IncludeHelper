Write-Information -Message ("Loading {0} ..." -f ($PSScriptRoot | Split-Path -Leaf)) -InformationAction continue

#Module path is where resides the RootModule file. This file. :)
$MODULE_PATH = $PSScriptRoot

# Load ps1 files on code folders in order
"config","helper","include","private","public" | ForEach-Object {

    Get-ChildItem -Path $MODULE_PATH\$_\*.ps1 -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        try { . $_.fullname }
        catch { Write-Error -Message "Failed to import function $($import.fullname): $_" }
    }
}

Export-ModuleMember -Function Test_*

