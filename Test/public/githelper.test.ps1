function Test_TestRepoFileChanged_Changed{

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    
    $repo = "reponame"
    New-TestingFolder -Path $repo
    git init $repo
    
    # Arrange Not changed
    $folder = "folder1/folder2"
    $file = "file1.txt"
    New-TestingFile -Path "$repo/$folder" -Name $file -Content "Hello World"
    $targetpath = Join-Path -Path $repo -childPath $folder -AdditionalChildPath $file

    # Act
    $result = Test-RepoFileChanged -Path $targetpath

    # Assert
    Assert-IsTrue -Condition $result

    # Arrange Not Changed
    git -C $repo add .
    git -C $repo commit -m "Initial commit"

    # Act
    $result = Test-RepoFileChanged -Path $targetpath
    
    # Assert
    Assert-IsFalse -Condition $result -Comment "File should not be marked as changed after commit"

    # Arrange change the file again
    Set-Content -Path $targetpath -Value "Hello World Changed"

    # Act
    $result = Test-RepoFileChanged -Path $targetpath

    # Assert
    Assert-IsTrue -Condition $result -Comment "File should be marked as changed after modification"
}
