
# CONFIG MOCK 
#
# This file is used to mock the config path and the config file
# for the tests. It creates a mock config path and a mock config file
# and sets the config path to the mock config path.
# We need to define varaibles for this include to work
# $MOCK_CONFIG_PATH : The path use as the mock config folder
# $CONFIG_INVOKE_GET_ROOT_PATH_CMD : Invoke comand that is needed to be mocked
#
# Sample file
# # CONFIG MOCK VARIABLES
# # This file is required for CONFIF MOCK to work
# $CONFIG_INVOKE_GET_ROOT_PATH_CMD = "Invoke-SfGetConfigRootPath" 
# $MOCK_CONFIG_PATH = "test_config_path"

function Mock_Config{
    param(
        [Parameter(Position=0)][string] $key = "config",
        [Parameter(Position=1)][object] $Config
    )

    $MOCK_CONFIG_PATH = "test_config_path"

    # Remove mock config path if exists
    if(Test-Path $MOCK_CONFIG_PATH){
        Remove-Item -Path $MOCK_CONFIG_PATH -ErrorAction SilentlyContinue -Recurse -Force
    }

    # create mock config path
    New-Item -Path $MOCK_CONFIG_PATH -ItemType Directory -Force

    # if $config is not null save it to a file
    if($null -ne $Config){
        $configfile = Join-Path -Path $MOCK_CONFIG_PATH -ChildPath "$key.json"
        $Config | ConvertTo-Json -Depth 10 | Set-Content $configfile
    }

    # Mock invoke call
    MockCallToString $CONFIG_INVOKE_GET_ROOT_PATH_CMD -OutString $MOCK_CONFIG_PATH

}