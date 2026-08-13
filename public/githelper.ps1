function Test-RepoFileChanged {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Path
    )

    process {
        try {
            if ([string]::IsNullOrWhiteSpace($Path)) {
                return $false
            }

            # convert to full routed path
            $absolutePath = $Path | Convert-Path

            "Testing [$Path] converted to absolute path [$absolutePath]" | Write-MyDebug -Section "githelper"

            # Get the reporoot. needed for git commands
            $parentDir = Split-Path -Path $absolutePath -Parent
            $repoRoot = git -C $parentDir rev-parse --show-toplevel  2>$null
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
                "Not a git repository: $parentDir" | Write-MyDebug -Section "githelper"
                return $false
            }
            
            # Check status of the file using absolute path and repo root
            $status = (& git -C $repoRoot status --porcelain -- $absolutePath 2>$null)
            $ret = -not [string]::IsNullOrWhiteSpace($status)

            # return 
            "Testing [$ret] for [$Path] absolute path [$absolutePath] repoRoot [$repoRoot] status [$status]" | Write-MyDebug -Section "githelper"
            return $ret
        }
        catch {
            "Error occurred while testing [$Path]: $_" | Write-MyDebug -Section "githelper"
            return $false
        }
    }
} Export-ModuleMember -Function Test-RepoFileChanged