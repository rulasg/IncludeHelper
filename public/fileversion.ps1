function Update-VersionToFile{
    [CmdletBinding()]
    [outputtype([bool])]
     param(
         [string]$Path,
         [string]$Version
     )

     # Return of file does not exist
     if(-not (Test-Path -Path $Path)){
        throw "File $Path not found"
     }

     $json = @{
         Version = $Version
         Date = (Get-Date).ToString("yyyy-MM-dd")
     } | ConvertTo-Json -Depth 3 -Compress
     $tragetFirstLine = "# $json"

     # read content
     $content = Get-Content -Path $Path

     # Read first line
     $firstLine =$content.Count -eq 0 ? "" : $content[0]


     # Check if first line containes 
     if ($firstLine -match '^\s*#\s*\{"Version":".*"\s*,\s*"Date":"[0-9]{4}-[0-9]{2}-[0-9]{2}"\s*\}\s*$') {
        # Replace the first line with the new version header
        $newContent = $content
        $newContent[0] = $tragetFirstLine
    }
    else {
        # Add the new version header as the first line of the file
        $newContent = @($tragetFirstLine) + $content
    }

    # Set value and return true
    # Do not use Set-Content as it adds a last line break, use Out-File instead
    $newContent -join "`n" | Out-File -Path $Path -NoNewline
    return $true

} Export-ModuleMember -Function Update-VersionToFile