function Test_GetIncludeFile{
    # Test for Include
    $name = "getHashCode.ps1"
    $folderName = "Include"

    $includelist =@()

    $expectedList = @("Include","TestInclude","Helper","TestHelper")

    $expectedList| ForEach-Object{
        $includelist += Get-ModuleFolder -FolderName $_ | Get-ChildItem -File
    }

    #Act all includes
    $result = Get-IncludeFile

    # Total number
    Assert-Count -Expected $includelist.Count -Presented $result
    # Assert random file
    $item = $result | Where-Object {$_.Name -eq $name}
    Assert-Count -Expected 1 -Presented $item
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName

    # Act filtered
    $result = Get-IncludeFile -Filter "config"
    $includesListFiltered = $includelist | Where-Object {$_.Name -like "*config*"}
    Assert-Count -Expected $includesListFiltered.Count -Presented $result
    # Assert random files
    $item = $result | Where-Object {$_.Name -eq "config.ps1"}
    Assert-AreEqual -Expected $folderName -Presented $item.FolderName
    $item = $result | Where-Object {$_.Name -eq "config.mock.ps1"}
    Assert-AreEqual -Expected "TestInclude" -Presented $item.FolderName
}

function Test_GetIncludeSystemFiles {
    # Test for IncludeSystemFiles

    $expectedList = @(

        # Root
        @{ FolderName = "Root" ;             Name = "{modulename}.psm1"                                 }
        @{ FolderName = "Root" ;             Name = "deploy.ps1"                                        }
        @{ FolderName = "Root" ;             Name = "LICENSE"                                           }
        @{ FolderName = "Root" ;             Name = "release.ps1"                                       }
        @{ FolderName = "Root" ;             Name = "sync.ps1"                                          }
        @{ FolderName = "Root" ;             Name = "test.ps1"                                          }

        # Tools
        @{ FolderName = "Tools" ;            Name = "deploy.Helper.ps1"                                 }
        @{ FolderName = "Tools" ;            Name = "sync.Helper.ps1"                                   }

        # TestRoot
        @{ FolderName = "TestRoot" ;         Name = "Test.psm1"                                         }

        # Workflows
        @{ FolderName = "WorkFlows" ;        Name = "deploy_module_on_release.yml"                      }
        @{ FolderName = "WorkFlows" ;        Name = "powershell.yml"                                    }
        @{ FolderName = "WorkFlows" ;        Name = "test_with_TestingHelper.yml"                       }

        # @{ FolderName = "DevContainer" ;     Name = "devcontainer.json"                                 }

        # @{ FolderName = "GitHub" ;           Name = "copilot-commit-message-instructions.md"            }
        # @{ FolderName = "GitHub" ;           Name = "copilot-instructions.md"                           }
        # @{ FolderName = "GitHub" ;           Name = "copilot-pull-request-description-instructions.md"  }

        # @{ FolderName = "TestHelperRoot" ;   Name = "Test_Helper.psd1"                                  }
        # @{ FolderName = "TestHelperRoot" ;   Name = "Test_Helper.psm1"                                  }

        # @{ FolderName = "TestHelperPublic" ; Name = "Get-RequiredModule.ps1"                            }
        # @{ FolderName = "TestHelperPublic" ; Name = "Import-RequiredModule.ps1"                         }
        # @{ FolderName = "TestHelperPublic" ; Name = "testname.ps1"                                      }
        # @{ FolderName = "TestHelperPublic" ; Name = "testResults.ps1"                                   }

        # @{ FolderName = "VsCode" ;           Name = "settings.json"                                     }
        # @{ FolderName = "VsCode" ;           Name = "launch.json"                                       }

    )

    $systemFolders = @(
        # 'Root',
        # 'Include',
        'DevContainer',
        # 'WorkFlows',
        'GitHub',
        # 'Config',
        # 'Helper',
        # 'Private',
        # 'Public',
        # 'Tools',

        # 'TestRoot',
        # 'TestConfig'
        # 'TestInclude',
        # 'TestHelper',
        # 'TestPrivate',
        # 'TestPublic',

        # "TestHelperRoot",
        "TestHelperPrivate",
        "TestHelperPublic",

        "VsCode"
    )

    # Add files from foldes that more files
    foreach($folderName in $systemFolders){
        $folder = Get-ModuleFolder -FolderName $folderName

        # Skipp if folder does not exist
        if(-not $($folder | Test-Path)){ continue }

        # Add files that exist in the folder
        $files = $folder | Get-ChildItem -File
        foreach($file in $files){
            $expectedList += @{ FolderName = $folderName ; Name = $file.Name }
        }
    }

    # Act
    $result = Get-IncludeSystemFiles

    # Assert
    Assert-Count -Expected $expectedList.Count -Presented $result

    foreach($Item in $expectedList){
        Assert-IncludeFile -Name $Item.Name -FolderName $Item.FolderName -IncludesList $result
    }

}

function Assert-IncludeFile{
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$FolderName,
        [Parameter(Mandatory)][array]$IncludesList
    )

    $item = $IncludesList | Where-Object {$_.Name -eq $Name}
    Assert-Count -Expected 1 -Presented $item
    Assert-AreEqual -Expected $FolderName -Presented $item.FolderName -Comment "Include File $Name should be in folder $FolderName"
}