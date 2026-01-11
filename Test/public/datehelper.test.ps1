function Test_GetDaysBetweenDates_SameDates {
    Invoke-PrivateContext {
        # Arrange
        $startDate = "2025-01-15"
        $endDate = "2025-01-15"

        # Act
        $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

        # Assert
        Assert-AreEqual -Expected 0 -Presented $result
    }
}

function Test_GetDaysBetweenDates_PositiveRange {
    Invoke-PrivateContext {
        # Arrange
        $startDate = "2025-01-01"
        $endDate = "2025-01-10"

        # Act
        $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

        # Assert
        Assert-AreEqual -Expected 9 -Presented $result
    }
}

function Test_GetDaysBetweenDates_NegativeRange {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $startDate = "2025-01-10"
        $endDate = "2025-01-01"

        $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate
        Assert-AreEqual -Expected 9 -Presented $result
    }
}

function Test_GetDaysBetweenDates_OneYear {
        Invoke-PrivateContext {
    # Arrange
    $startDate = "2025-01-01"
    $endDate = "2026-01-01"

    # Act
    $result = Get-DaysBetweenDates -StartDate $startDate -EndDate $endDate

    # Assert
    Assert-AreEqual -Expected 365 -Presented $result
        }
}

function Test_GetDaysBetweenDates_DefaultStartDate {
    # Arrange
    Reset-InvokeCommandMock

    $now = Get-Date -Format 'yyyy-MM-dd'
    MockCallToObject -Command "GetNow" -OutObject $now

    # Act & Assert
    Invoke-PrivateContext {
        $futureDate = (Get-Date).AddDays(10) | Get-Date -Format 'yyyy-MM-dd'

        $result = Get-DaysBetweenDates -EndDate $futureDate
        
        # Result should be approximately 10 days (allowing for same-day test execution)
        Assert-AreEqual -Expected 10 -Presented $result
    }
}

function Test_ConvertFromEpochTime_OneDay {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $epochTime = 86400  # One day in seconds

        $result = ConvertFrom-EpochTime -EpochTime $epochTime
        $expected = [datetime]::UnixEpoch.AddSeconds(86400)
        Assert-AreEqual -Expected $expected -Presented $result
    }
}

function Test_ConvertFromEpochTime_LargeValue {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $epochTime = 1609459200  # 2021-01-01 00:00:00 UTC

        $result = ConvertFrom-EpochTime -EpochTime $epochTime
        Assert-IsTrue -Condition ($result -is [datetime])
        Assert-AreEqual -Expected 2021 -Presented $result.Year
        Assert-AreEqual -Expected 1 -Presented $result.Month
        Assert-AreEqual -Expected 1 -Presented $result.Day
    }
}

function Test_ConvertFromEpochTime_ZeroEpochTime {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $epochTime = 0

        $result = ConvertFrom-EpochTime -EpochTime $epochTime
        Assert-AreEqual -Expected 1970 -Presented $result.Year
    }

    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $dateTime = [datetime]::UnixEpoch

        $result = ConvertTo-EpochTime -DateTime $dateTime
        Assert-AreEqual -Expected 0 -Presented $result
    }
}

function Test_ConvertToEpochTime_OneDay {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $dateTime = [datetime]::UnixEpoch.AddDays(1)

        $result = ConvertTo-EpochTime -DateTime $dateTime
        Assert-AreEqual -Expected 86400 -Presented $result
    }
}

function Test_ConvertToEpochTime_RecentDate {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $dateTime = [datetime]::new(2021, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

        $result = ConvertTo-EpochTime -DateTime $dateTime
        Assert-AreEqual -Expected 1609459200 -Presented $result
    }
}

function Test_ConvertToEpochTime_ReturnsLong {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $dateTime = [datetime]::UtcNow

        $result = ConvertTo-EpochTime -DateTime $dateTime
        Assert-IsTrue -Condition ($result -is [long])
    }
}

function Test_ConvertToEpochTime_RoundTrip {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $original = [datetime]::new(2020, 6, 15, 12, 30, 45, [System.DateTimeKind]::Utc)

        $epochTime = ConvertTo-EpochTime -DateTime $original
        $restored = ConvertFrom-EpochTime -EpochTime $epochTime

        Assert-AreEqual -Expected $original -Presented $restored
    }
}

function Test_ConvertFromEpochTime_NegativeValue {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $epochTime = -86400  # One day before epoch

        $result = ConvertFrom-EpochTime -EpochTime $epochTime
        $expected = [datetime]::UnixEpoch.AddSeconds(-86400)
        Assert-AreEqual -Expected $expected -Presented $result
    }
}

function Test_ConvertToEpochTime_BeforeEpoch {
    # Act & Assert
    Invoke-PrivateContext {
        # Arrange
        $dateTime = [datetime]::UnixEpoch.AddDays(-1)

        $result = ConvertTo-EpochTime -DateTime $dateTime
     

        # Assert
        Assert-AreEqual -Expected -86400 -Presented $result
    }
}
