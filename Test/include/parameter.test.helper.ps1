# Variables used to the written output of the cmdlets
#
# This definition allows to trace output streams for testing purposes
#
# sample usage:
#
# function Get-SomeCommand {
#    [CmdletBinding()]
#    param()
#
#    Write-Verbose "this is a verbose message"
# }
#
# $result = Get-SomeCommand @ VerboseParameters
# Assert-Contains -Expected "this is a verbose message" -Presented $verboseVar

# Verbose parameters will now work.to capture the verbose outptut pipe 4>&1 and capture the output
# [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','',Scope='function')]
# $VerboseParameters =@{
#     VerboseAction = 'SilentlyContinue'
#     VerboseVariable = 'verboseVar'
# }

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