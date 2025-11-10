# Feature Flag
#
# Feature Flags management module
#
# Include design description
# This module depends on Config Include
# This module will allow set Feature Flags to the module to quicker release 
# features with less risk
#


function Get-FeatureFlags{
    [CmdletBinding()]
    param()

    $config = Get-Configuration

    if(! $config){
        return @{}
    }

    if(! $config.FeatureFlags){
        $config.FeatureFlags = @{}
    }

    return $config.FeatureFlags
}

function Save-FeatureFlags{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][hashtable]$FeatureFlags
    )

    $config = Get-Configuration

    if(! $config){
        $config = @{}
    }

    if(! $config.FeatureFlags){
        $config.FeatureFlags = @{}
    }


    $config.FeatureFlags = $FeatureFlags
    
    Save-Configuration -Config $config
}

function Test-FeatureFlag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key
    )

    $ffs = Get-FeatureFlags

    $value = $ffs.$key

    return $value -eq $true
}

function Set-FeatureFlag{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key,
        [Parameter()][bool]$Value = $true

    )

    $featureFlags = Get-FeatureFlags

    $featureFlags.$Key = $Value

    Save-FeatureFlags $featureFlags

}

function Clear-FeatureFlag{
        [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Key

    )

    Set-FeatureFlag -Key $Key -Value $false

}