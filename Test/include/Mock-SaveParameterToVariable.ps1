# Mock-SaveParameterToVariable
#
# Allows mocking commands using a temp varible for the content.
#
# When the parameters for an invoke is too big as string, we can use a json
# as a single parameter to hold all the parameters wanted.
#
# We can use this Mock functions to mock the calls to this invokes that use a json to 
# transfer an object as parameter.

function Reset-MockSaveParameterToVariable {

    $script:varCommands = @{}
}

function Get-MockSavedParameterFromVariable ($Command){

    $result = $script:varCommands[$Command]

    if ($nulll -eq $result) {
        throw "Command [$Command] was not initialized."
    }

    return $result

}

function Invoke-MockSaveParameterToVariable{
    param(
        [Parameter(Position=0)][string] $Command,
        [Parameter(Position=1)][string] $json,
        [Parameter(Position=2)][string] $FileName,
        [Parameter()][switch] $ashashtable
    )

    # Save call to Variable
    $script:varCommands.$Command += $json

    # Return some value from FielName if provided
    if(-Not [string]::IsNullOrWhiteSpace($FileName)){

        $ret = Get-MockFileContentJson -filename $FileName -asHashtable:$ashashtable

        return $ret
    }

} Export-ModuleMember -Function Invoke-MockSaveParameterToVariable

function MockCallJson_SaveParametersToVariable{
    param(
        [Parameter(Position=0)][string] $command,
        [Parameter(Position=2)][string] $fileName,
        [Parameter()][switch] $ashashtable
    )

    # Prepare variable to receive calls
    $script:varCommands.$Command = @()

    # Mock call back leaving {json} as the parameter to be replaced by the call
    $mockCommand = 'Invoke-MockSaveParameterToVariable "{command}" ''{json}'' "{fileName}" -ashashtable:${ashashtable}'
    $mockCommand = $mockCommand -replace "{command}", $command
    $mockCommand = $mockCommand -replace "{fileName}", $fileName
    $mockCommand = $mockCommand -replace "{json}", '{json}'
    $mockCommand = $mockCommand -replace "{ashashtable}", $ashashtable.IsPresent.ToString()

    # Set invoke command mock with the prepared command
    Set-InvokeCommandMock -Alias $command -Command $mockCommand

  }