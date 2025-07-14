filter Select-IncludeFileByFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline = $true)]
        [PSObject]
        $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [string]
        $FolderName
    )
    
    # Check if the object has a FolderName property and if it matches the specified value
    if ($InputObject.FolderName -Like "$FolderName") {
        $InputObject
    }
} Export-ModuleMember -Function 'Select-IncludeFileByFolder'
