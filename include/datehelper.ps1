
# DATE HELPER
#
# Date and time utility functions including epoch time conversion
#
# This module provides functions for:
# - Calculating days between dates
# - Converting to/from Unix epoch time
# - Getting current date and time (with Invoke-MyCommand pattern for testability)
#

Set-MyInvokeCommandAlias -Alias GetNow -Command "Get-Date -Format 'yyyy-MM-dd'"
Set-MyInvokeCommandAlias -Alias GetUtcNow -Command "Get-Date -AsUTC"

function Get-DaysBetweenDates {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$StartDate,
        [Parameter(Mandatory, Position = 1)][string]$EndDate
    )

    if ([string]::IsNullOrWhiteSpace($StartDate)) {
        $StartDate = Invoke-MyCommand -Command GetNow
    }

    $start = [DateTime]::ParseExact($StartDate, 'yyyy-MM-dd', $null)
    $end = [DateTime]::ParseExact($EndDate, 'yyyy-MM-dd', $null)
    
    $timeSpan = $end - $start
    
    return [Math]::Abs($timeSpan.Days)
}

function Get-EpochTime {
    [CmdletBinding()]
    [OutputType([long])]
    param()
    
    $epoch = [datetime]::UnixEpoch
    $now = Invoke-MyCommand -Command GetUtcNow
    $timeSpan = $now - $epoch
    
    return [long]$timeSpan.TotalSeconds
}

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
}

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
}
