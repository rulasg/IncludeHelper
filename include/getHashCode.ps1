
# Get HASH CODE
#
# This script defines a function to compute the MD5 hash of a given string.
# The hash is returned as a hexadecimal string without dashes.
# The function is useful for generating unique keys based on input strings,
# such as for caching purposes in a database or other storage.
# The hash generated is equal on all environments making it usedfull across computers.

function Get-HashCode {
    param (
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        [string]$InputString
    )

    process{
        # Generate MD5 hash
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $hashBytes = $md5.ComputeHash($bytes)
        $hashString = [BitConverter]::ToString($hashBytes) -replace '-', ''
        
        return $hashString
    }

}