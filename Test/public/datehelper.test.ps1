function Test_GetDaysBetweenDates_SameDates {
    # Arrange
    $startDate = "2025-01-15"
    $endDate = "2025-01-15"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 0 -Presented $result
}

function Test_GetDaysBetweenDates_PositiveRange {
    # Arrange
    $startDate = "2025-01-01"
    $endDate = "2025-01-10"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 9 -Presented $result
}

function Test_GetDaysBetweenDates_NegativeRange {
    # Arrange
    $startDate = "2025-01-10"
    $endDate = "2025-01-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 9 -Presented $result
}

function Test_GetDaysBetweenDates_OneYear {
    # Arrange
    $startDate = "2025-01-01"
    $endDate = "2026-01-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 365 -Presented $result
}

function Test_GetDaysBetweenDates_DefaultStartDate {
    # Arrange
    $today = Get-Date -Format 'yyyy-MM-dd'
    $tomorrow = (Get-Date).AddDays(1) | Get-Date -Format 'yyyy-MM-dd'

    # Act
    $result = Get-DaysBetweenDates -EndDate $tomorrow

    # Assert
    Assert-AreEqual -Expected 1 -Presented $result
}

function Test_GetDaysBetweenDates_LeapYear {
    # Arrange
    $startDate = "2024-02-29"  # Leap day
    $endDate = "2024-03-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 1 -Presented $result
}

function Test_GetDaysBetweenDates_DecadeRange {
    # Arrange
    $startDate = "2015-01-01"
    $endDate = "2025-01-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    # 10 years with 3 leap years (2016, 2020, 2024) = 7*365 + 3*366 = 3653 days
    Assert-AreEqual -Expected 3653 -Presented $result
}

function Test_GetEpochTime_ReturnsLong {
    # Arrange & Act
    $result = Get-EpochTime

    # Assert
    Assert-IsTrue -Condition ($result -is [long])
}

function Test_GetEpochTime_PositiveValue {
    # Arrange
    $unixEpoch = [datetime]::UnixEpoch
    $now = [datetime]::UtcNow
    $expectedMinimum = ($now - $unixEpoch).TotalSeconds - 10  # Allow 10 second margin

    # Act
    $result = Get-EpochTime

    # Assert
    Assert-IsTrue -Condition ($result -ge $expectedMinimum)
}

function Test_GetEpochTime_ReturnsCurrentTime {
    # Arrange
    $before = Get-EpochTime
    Start-Sleep -Seconds 1
    
    # Act
    $after = Get-EpochTime

    # Assert
    Assert-IsTrue -Condition ($after -gt $before)
}

function Test_ConvertFromEpochTime_ValidEpochTime {
    # Arrange
    $epochTime = 0  # Unix epoch: 1970-01-01 00:00:00

    # Act
    $result = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    Assert-AreEqual -Expected ([datetime]::UnixEpoch) -Presented $result
}

function Test_ConvertFromEpochTime_OneDay {
    # Arrange
    $epochTime = 86400  # One day in seconds

    # Act
    $result = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    $expected = [datetime]::UnixEpoch.AddSeconds(86400)
    Assert-AreEqual -Expected $expected -Presented $result
}

function Test_ConvertFromEpochTime_LargeValue {
    # Arrange
    $epochTime = 1609459200  # 2021-01-01 00:00:00 UTC

    # Act
    $result = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    Assert-IsTrue -Condition ($result -is [datetime])
    Assert-AreEqual -Expected 2021 -Presented $result.Year
    Assert-AreEqual -Expected 1 -Presented $result.Month
    Assert-AreEqual -Expected 1 -Presented $result.Day
}

function Test_ConvertFromEpochTime_ZeroEpochTime {
    # Arrange
    $epochTime = 0

    # Act
    $result = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    Assert-AreEqual -Expected 1970 -Presented $result.Year
}

function Test_ConvertToEpochTime_UnixEpoch {
    # Arrange
    $dateTime = [datetime]::UnixEpoch

    # Act
    $result = ConvertTo-EpochTime -DateTime $dateTime

    # Assert
    Assert-AreEqual -Expected 0 -Presented $result
}

function Test_ConvertToEpochTime_OneDay {
    # Arrange
    $dateTime = [datetime]::UnixEpoch.AddDays(1)

    # Act
    $result = ConvertTo-EpochTime -DateTime $dateTime

    # Assert
    Assert-AreEqual -Expected 86400 -Presented $result
}

function Test_ConvertToEpochTime_RecentDate {
    # Arrange
    $dateTime = [datetime]::new(2021, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

    # Act
    $result = ConvertTo-EpochTime -DateTime $dateTime

    # Assert
    Assert-AreEqual -Expected 1609459200 -Presented $result
}

function Test_ConvertToEpochTime_ReturnsLong {
    # Arrange
    $dateTime = [datetime]::UtcNow

    # Act
    $result = ConvertTo-EpochTime -DateTime $dateTime

    # Assert
    Assert-IsTrue -Condition ($result -is [long])
}

function Test_ConvertToEpochTime_RoundTrip {
    # Arrange
    $original = [datetime]::new(2020, 6, 15, 12, 30, 45, [System.DateTimeKind]::Utc)

    # Act
    $epochTime = ConvertTo-EpochTime -DateTime $original
    $restored = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    Assert-AreEqual -Expected $original -Presented $restored
}

function Test_GetDaysBetweenDates_CrossYears {
    # Arrange
    $startDate = "2024-12-31"
    $endDate = "2025-01-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 1 -Presented $result
}

function Test_ConvertFromEpochTime_NegativeValue {
    # Arrange
    $epochTime = -86400  # One day before epoch

    # Act
    $result = ConvertFrom-EpochTime -EpochTime $epochTime

    # Assert
    $expected = [datetime]::UnixEpoch.AddSeconds(-86400)
    Assert-AreEqual -Expected $expected -Presented $result
}

function Test_ConvertToEpochTime_BeforeEpoch {
    # Arrange
    $dateTime = [datetime]::UnixEpoch.AddDays(-1)

    # Act
    $result = ConvertTo-EpochTime -DateTime $dateTime

    # Assert
    Assert-AreEqual -Expected -86400 -Presented $result
}
