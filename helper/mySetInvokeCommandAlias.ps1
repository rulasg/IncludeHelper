
# SET MY INVOKE COMMAND ALIAS
#
# Allows calling constitely InvokeHelper with the module tag
# Need to define a variable called $MODULE_INVOKATION_TAG
#
# Sample:
# $MODULE_INVOKATION_TAG = "SfHelperModule"

function Set-MyInvokeCommandAlias{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    # throw if MODULE_INVOKATION_TAG is not set or is "MyModuleModule"
    if (-not $MODULE_INVOKATION_TAG -or $MODULE_INVOKATION_TAG -eq "MyModuleModule") {
        throw "MODULE_INVOKATION_TAG is not set or has an invalid value ('MyModuleModule'). Please set it to a unique value before calling Set-MyInvokeCommandAlias."
    }

    if ($PSCmdlet.ShouldProcess("InvokeCommandAliasList", ("Add Command Alias [{0}] = [{1}]" -f $Alias, $Command))) {
        InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG
    }
}