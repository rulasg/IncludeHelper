function Remove-TailSpacesAndLines {
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]] $Path = '.',
        [Parameter()][switch] $Recurse
    )

    process {

        $files = Get-ChildItem -Path $Path -File -force -Recurse:$Recurse -Include *.ps1, *.psm1, *.psd1, *.json, *.yml, *.yaml, *.md, *.txt, *.xml

        # Remove .git content (exact .git folder only, not .github)
        $files = $files | Where-Object { $_.FullName -notmatch '(^|[\\/])\.git[\\/]' }

        foreach ($file in $files) {

            Write-Verbose "Processing file: $($file.FullName)"

            $dirty = $false

            $content = Get-Content -Path $file.FullName
            $newContent = @()

            # Trim each line
            foreach ($line in $content) {

                if([string]::IsNullOrWhiteSpace($line)) {
                    $newLine = ""
                } else {
                    $newLine = $line.TrimEnd()
                }

                $newContent += $newLine

                if($newLine -ne $line) {
                    $dirty = $true
                }
            }

            # Remove trailing empty lines
            while (($newContent.count -ne 0) -and ([string]::IsNullOrWhiteSpace($newContent[-1]))) {
                $newContent = $newContent[0..($newContent.Count - 2)]
                $dirty = $true
            }

            if($dirty) {
                Set-Content -Path $file.FullName -Value $newContent
                Write-Output $file.FullName
            }
        }
    }
}
