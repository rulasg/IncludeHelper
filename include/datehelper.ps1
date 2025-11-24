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

function Get-EpochTime {
    [CmdletBinding()]
    [OutputType([long])]
    param()
    
    $epoch = [datetime]::UnixEpoch
    $now = [datetime]::UtcNow
    $timeSpan = $now - $epoch
    
    return [long]$timeSpan.TotalSeconds
} Export-ModuleMember -Function Get-EpochTime

function ConvertFrom-EpochTime {
    [CmdletBinding()]
    [OutputType([datetime])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [long]$EpochTime
    )
    
    $epoch = [datetime]::UnixEpoch
    $dateTime = $epoch.AddSeconds($EpochTime)
    
    return $dateTime
} Export-ModuleMember -Function ConvertFrom-EpochTime

function ConvertTo-EpochTime {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [datetime]$DateTime
    )
    
    $epoch = [datetime]::UnixEpoch
    $timeSpan = $DateTime.ToUniversalTime() - $epoch
    
    return [long]$timeSpan.TotalSeconds
} Export-ModuleMember -Function ConvertTo-EpochTime
