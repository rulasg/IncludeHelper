
$mockDate = "1975-02-18 00:12:15"
$mockDatetime = [DateTime]::ParseExact($mockDate, 'yyyy-MM-dd HH:mm:ss', $null)
$mockDatetimeUtc = [DateTime]::SpecifyKind($mockDatetime, [DateTimeKind]::Utc)

function Mock_GetToday{

    return $mockDatetime

}

function MockCall_DateHelper {

    MockCallToObject -command "Get-Date" -OutObject $mockDatetime
    MockCallToObject -command "Get-Date -Format 'yyyy-MM-dd'" -OutObject $mockDatetime.ToString("yyyy-MM-dd")
    MockCallToObject -command "Get-Date -AsUTC" -OutObject $mockDatetimeUtc
}
