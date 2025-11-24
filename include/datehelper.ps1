function Get-DaysBetweenDates {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$StartDate = (Get-Date -Format 'yyyy-MM-dd'),
        [Parameter(Mandatory, Position = 1)][string]$EndDate
    )

    $start = [DateTime]::ParseExact($StartDate, 'yyyy-MM-dd', $null)
    $end = [DateTime]::ParseExact($EndDate, 'yyyy-MM-dd', $null)
    
    $timeSpan = $end - $start
    
    return [Math]::Abs($timeSpan.Days)
} Export-ModuleMember -Function Get-DaysBetweenDates