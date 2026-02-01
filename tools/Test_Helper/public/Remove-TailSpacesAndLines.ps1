function Remove-TailSpacesAndLines {
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]] $Path = '.',
        [Parameter()][switch] $Recurse
    )

    process {

        # $files = Get-ChildItem -Path $Path -File -force -Recurse:$Recurse -Include *.ps1, *.psm1, *.psd1, *.json, *.yml, *.yaml, *.md, *.txt, *.xml
        $files = Get-ChildItem -Path $Path -File -force -Recurse:$Recurse

        # Remove .git content (exact .git folder only, not .github)
        $files = $files | Where-Object { $_.FullName -notmatch '(^|[\\/])\.git[\\/]' }

        foreach ($file in $files) {

            Write-Verbose "Processing file: $($file.FullName)"

            # Remove tail spaces
            $dirty_Spaces = Remove-TailSpacesFromLines -Path $file.FullName

            # Remove tail empty lines
            $dirty_Lines = Remove-TailEmptyLines -Path $file.FullName

            # Write file path if modified
            if($dirty_Spaces -or $dirty_Lines) {
                Write-Output $file.FullName
            }
        }
    }
} Export-ModuleMember -Function Remove-TailSpacesAndLines

function Remove-TailEmptyLines {
    <#
    .SYNOPSIS
        Removes all trailing empty lines from a text file.
    .DESCRIPTION
        Reads a file and removes any empty or whitespace-only lines from the end.
        Returns $true if any lines were removed, $false if no changes were needed.
    .PARAMETER Path
        The path to the file to process.
    .OUTPUTS
        System.Boolean - $true if lines were removed, $false otherwise.
    .EXAMPLE
        Remove-TailEmptyLines -Path "myfile.ps1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path
    )

    process {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Error "File not found: $Path"
            return $false
        }

        $content = Get-Content -Path $Path
        $originalCount = $content.Count

        # Handle empty file
        if ($originalCount -eq 0) {
            return $false
        }

        # Remove trailing empty lines
        $newContent = $content
        while (($newContent.Count -gt 0) -and ([string]::IsNullOrWhiteSpace($newContent[-1]))) {
            $newContent = $newContent[0..($newContent.Count - 2)]
        }

        $linesRemoved = $originalCount -ne $newContent.Count

        if ($linesRemoved) {
            # Join array with newlines first, then use -NoNewline to avoid trailing newline

            # $joinedContent = $newContent -join [Environment]::NewLine
            # Set-Content -Path $Path -Value $joinedContent -NoNewline

            Set-MyContent -Path $Path -Value $newContent
            return $true
        }

        return $false

    }
} Export-ModuleMember -Function Remove-TailEmptyLines

function Set-MyContent {
    param (
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][object[]] $Value
    )

    # Join string array to single string
    $joinedValue = $Value -join [Environment]::NewLine

    # Write content without trailing newline
    Set-Content -Path $Path -Value $joinedValue -NoNewline
}

function Test-TailEmptyLines {
    <#
    .SYNOPSIS
        Tests if a file has trailing empty lines.
    .DESCRIPTION
        Checks if a file ends with one or more empty or whitespace-only lines.
        Returns $true if trailing empty lines exist, $false otherwise.
    .PARAMETER Path
        The path to the file to check.
    .OUTPUTS
        System.Boolean - $true if file has trailing empty lines, $false otherwise.
    .EXAMPLE
        Test-TailEmptyLines -Path "myfile.ps1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path
    )

    process {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Error "File not found: $Path"
            return $false
        }

        $content = Get-Content -Path $Path

        # Empty file has no trailing empty lines
        if ($content.Count -eq 0) {
            return $false
        }

        # Check if last line is empty or whitespace-only
        return [string]::IsNullOrWhiteSpace($content[-1])
    }
} Export-ModuleMember -Function Test-TailEmptyLines

function Remove-TailSpacesFromLines {
    <#
    .SYNOPSIS
        Removes trailing spaces from all lines in a text file.
    .DESCRIPTION
        Reads a file and trims trailing whitespace from each line.
        Returns $true if any spaces were removed, $false if no changes were needed.
    .PARAMETER Path
        The path to the file to process.
    .OUTPUTS
        System.Boolean - $true if spaces were removed, $false otherwise.
    .EXAMPLE
        Remove-TailSpacesFromLines -Path "myfile.ps1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path
    )

    process {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Error "File not found: $Path"
            return $false
        }

        $content = Get-Content -Path $Path

        # Handle empty file
        if ($content.Count -eq 0) {
            return $false
        }

        $dirty = $false
        [string[]]$newContent = @()

        foreach ($line in $content) {
            $trimmedLine = $line.TrimEnd()
            $newContent += $trimmedLine

            if ($trimmedLine -ne $line) {
                $dirty = $true
            }
        }

        if ($dirty) {
            Set-MyContent -Path $Path -Value $newContent
        }

        return $dirty
    }
} Export-ModuleMember -Function Remove-TailSpacesFromLines

function Test-TailSpacesInLines {
    <#
    .SYNOPSIS
        Tests if a file has trailing spaces in any of its lines.
    .DESCRIPTION
        Checks if any line in the file ends with trailing whitespace.
        Returns $true if trailing spaces exist in any line, $false otherwise.
    .PARAMETER Path
        The path to the file to check.
    .OUTPUTS
        System.Boolean - $true if any line has trailing spaces, $false otherwise.
    .EXAMPLE
        Test-TailSpacesInLines -Path "myfile.ps1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path
    )

    process {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Error "File not found: $Path"
            return $false
        }

        $content = Get-Content -Path $Path

        # Empty file has no trailing spaces
        if ($content.Count -eq 0) {
            return $false
        }

        # Check if any line has trailing whitespace
        foreach ($line in $content) {
            if ($line -ne $line.TrimEnd()) {
                return $true
            }
        }

        return $false
    }
} Export-ModuleMember -Function Test-TailSpacesInLines
