# Variables used to the written output of the cmdlets
#
# This definition allows to trace output streams for testing purposes
#
# sample usage:
#
# function Get-DummyFunction{
#     [CmdletBinding()]
#     param()

#     Write-Error "Error Message from dummyFunction"
#     Write-Verbose "Verbose Message from dummyFunction"
#     Write-Warning "Warning Message from dummyFunction"
#     Write-Information "Information Message from dummyFunction"
#     Write-host "Host Message from dummyFunction"

#     return $true
# }

# $result = Get-DummyFunction @ErrorParameters @WarningParameters @InfoParameters

# Assert-IsTrue -Condition $result
# Assert-Contains -Expected "Error Message from dummyFunction" -Presented $errorVar[0].exception.Message
# Assert-Contains -Expected "Warning Message from dummyFunction" -Presented $warningVar
# Assert-Contains -Expected "Information Message from dummyFunction" -Presented $infoVar
# Assert-Contains -Expected "Host Message from dummyFunction" -Presented $infoVar

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$WarningParameters = @{
    WarningAction = 'SilentlyContinue'
    WarningVariable = 'warningVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$InfoParameters = @{
    InformationAction = 'SilentlyContinue'
    InformationVariable = 'infoVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
$ErrorParameters = @{
    ErrorAction = 'SilentlyContinue'
    ErrorVariable = 'errorVar'
}