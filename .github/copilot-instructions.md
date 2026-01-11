# Copilot Instructions for IncludeHelper

IncludeHelper is a PowerShell module that provides shared utility functions and a framework for distributing reusable code components ("includes") across other modules.

## Architecture Overview

**Module Structure:**
- `config/`: Configuration utilities and module initialization
- `helper/`: Core module helpers (module path resolution, folder management)
- `include/`: Shared utility functions (logging, API calls, database, config management)
- `private/`: Internal functions not exported
- `public/`: Exported functions (the public API)
- `Test/`: Mirrored structure with unit tests and mocks

**Loading Order** (in `IncludeHelper.psm1`): `config` → `helper` → `include` → `private` → `public`

## PowerShell Function Conventions

### All Functions
- Must include `[CmdletBinding()]` attribute
- Must include `param()` block (even if empty)
- Use proper script documentation with `<# .SYNOPSIS #>` blocks

### Public Functions (`public/` folder)
- Add `Export-ModuleMember -Function 'FunctionName'` on the closing `}` line
- Example:
  ```powershell
  function Add-IncludeToWorkspace {
      [CmdletBinding()]
      param([Parameter(Mandatory)][string]$Name)
      # Logic
  } Export-ModuleMember -Function 'Add-IncludeToWorkspace'
  ```

### Helper Functions (`helper/` folder)
- Available module-wide; follow naming convention: verbs that clearly indicate utility purpose
- Key helpers: `Find-ModuleRootPath`, `Get-ModuleFolder`, `Get-Ps1FullPath`

## Logging and Debugging

- Use `MyWrite.ps1` functions: `Write-MyError`, `Write-MyWarning`, `Write-MyVerbose`, `Write-MyDebug`, `Write-MyHost`
- Control verbosity via environment variables: `$env:ModuleHelper_VERBOSE="all"` or specific function names
- Control debugging via `$env:ModuleHelper_DEBUG="all"` or specific sections
- Test verbosity/debug state with `Test-MyVerbose` and `Test-MyDebug`

## Test Conventions

Tests use `TestingHelper` module and follow pattern: `function Test_FunctionName_Scenario`

**Test Structure:**
```powershell
function Test_AddIncludeToWorkspace {
    # Arrange - Setup test data and mocks
    Import-Module -Name TestingHelper
    New-ModuleV3 -Name TestModule
    
    # Act - Execute the function being tested
    Add-IncludeToWorkspace -Name "getHashCode.ps1" -FolderName "Include" -DestinationModulePath "TestModule"
    
    # Assert - Verify results
    Assert-ItemExist -path (Join-Path $folderPath "getHashCode.ps1")
}
```

- Use `Assert-NotImplemented` for unfinished tests
- Test files in `Test/public/` mirror functions in `public/`
- Run tests with `./test.ps1` (uses `TestingHelper` module)

## Core Patterns

**Module Discovery:** Use `Find-ModuleRootPath` to locate module root by searching up from current path for `*.psd1` files (skips Test.psd1).

**Folder Management:** `Get-ModuleFolder` maps logical names (`Include`, `Public`, `TestPrivate`, etc.) to filesystem paths. Valid names defined in `helper/module.helper.ps1` `$VALID_FOLDER_NAMES`.

**Configuration:** JSON-based, stored in `~/.helpers/{ModuleName}/config/`. Use `Get-Configuration`, `Save-Configuration`, `Test-Configuration` from `include/config.ps1`.

**Command Aliasing:** Use `Set-MyInvokeCommandAlias` and `Invoke-MyCommand` for mockable external commands (database calls, API invocations).

## Development Commands

- `./test.ps1` - Run all unit tests
- `./sync.ps1` - Sync includes to workspace/module
- `./deploy.ps1` - Deploy module
- `./release.ps1` - Release module version