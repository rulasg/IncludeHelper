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

            $absolutePath = if ([System.IO.Path]::IsPathRooted($Path)) {
                [System.IO.Path]::GetFullPath($Path)
            } else {
                [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
            }

            $candidateDir = if (Test-Path -LiteralPath $absolutePath -PathType Container) {
                $absolutePath
            } else {
                Split-Path -Path $absolutePath -Parent
            }

            if (-not (Test-Path -LiteralPath $candidateDir -PathType Container)) {
                return $false
            }

            $repoRoot = (& git -C $candidateDir rev-parse --show-toplevel 2>$null | Select-Object -First 1)
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
                return $false
            }
            $repoRoot = $repoRoot.Trim()

            $repoRootFull = [System.IO.Path]::GetFullPath($repoRoot)
            if ($absolutePath -notlike "$repoRootFull*") {
                return $false
            }

            $relativePath = [System.IO.Path]::GetRelativePath($repoRootFull, $absolutePath)
            $status = (& git -C $repoRootFull status --porcelain -- $relativePath 2>$null)

            return -not [string]::IsNullOrWhiteSpace(($status | Out-String).Trim())
        }
        catch {
            return $false
        }
    }
}