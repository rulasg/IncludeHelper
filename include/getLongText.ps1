
$EditFileAlias = $MODULE_NAME + "_EditFile"
Set-MyInvokeCommandAlias -Alias $EditFileAlias -Command "code -w {path}"

function Get-LongText{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Text
    )

    $tmpFilePath = "temp:" | Convert-Path | Join-Path -ChildPath "LongText_$([Guid]::NewGuid().ToString()).md"

    New-Item -Path $tmpFilePath -ItemType File -Force | Out-Null

    if( -not [string]::IsNullOrWhiteSpace($Text)){
        Set-Content -Path $tmpFilePath -Value $Text
    }

    Invoke-MyCommand -Command $EditFileAlias  -Parameters @{ path = $tmpFilePath }

    $content = Get-Content $tmpFilePath -Raw

    Remove-Item $tmpFilePath -Force

    Set-TextVariable $content

    return $content
}