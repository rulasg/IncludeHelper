Set-MyInvokeCommandAlias -Alias GetGhHandle -Command 'gh api user --jq ".login"'

function Get-MyHandle{
    [CmdletBinding()]
    param()
    
    $user = Invoke-MyCommand -Command GetGhHandle
    
    return $user
}