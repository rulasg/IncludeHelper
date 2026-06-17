function Get-IncludeFileVersion{
    [CmdletBinding()]
    param(
        [string]$Path
    )

    # Return of file does not exist
    if(-not (Test-Path -Path $Path)){
        throw "File $Path not found"
    }

    $content = Get-Content -Path $Path

    # If file is empty no version can be found
    if($null -eq $content){
        return $null
    }

    $version = Get-VersionHeader -content $content

    if($version){
        $ret = [PsCustomObject]@{
            Version = $version.Version
            Date = $version.Date
        }
    } else {
        $ret = $null
    }

    return $ret

} Export-ModuleMember -Function Get-IncludeFileVersion

