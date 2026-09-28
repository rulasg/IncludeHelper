function Test_FormatTagString{

    Invoke-PrivateContext{

        # Empty string
        $string = "" | Format-TagString
        Assert-AreEqual -Expected "" -Presented $string

        # String without tags
        $string = "Your string here" | Format-TagString
        Assert-AreEqual -Expected "Your string here" -Presented $string

        # Normalize a tag list at the front and its separator from the text
        $string = "[tag1]  [tag2]   Your string here" | Format-TagString
        Assert-AreEqual -Expected "[tag1][tag2] Your string here" -Presented $string

        # Normalize a tag list in the middle and its separators
        $string = "Your  string [tag1]  [tag2]   with more text" | Format-TagString
        Assert-AreEqual -Expected "Your  string [tag1][tag2] with more text" -Presented $string

        # Normalize a tag list at the end and its separator from the text
        $string = "Your string here   [tag1]  [tag2]  " | Format-TagString
        Assert-AreEqual -Expected "Your string here [tag1][tag2]" -Presented $string

        # Add a separator when text touches a tag list
        $string = "Your string[tag1][tag2]more text" | Format-TagString
        Assert-AreEqual -Expected "Your string [tag1][tag2] more text" -Presented $string

        # Normalize several tag lists in one string
        $string = "[front1] [front2] text [middle1]  [middle2] text [end1] [end2]" | Format-TagString
        Assert-AreEqual -Expected "[front1][front2] text [middle1][middle2] text [end1][end2]" -Presented $string
    }
}

function Test_AddTagToString{

    Invoke-PrivateContext{


        # Empty string
        $string = ""
        $string = $string | Add-TagToString "tag1"
        Assert-AreEqual -Expected "[tag1]" -Presented $string

        # Act - Add first tag
        $string = "Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag1"
        Assert-AreEqual -Expected "[tag1] Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Add second tag with space at the end of tag list
        $string = "[tag1] Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag2"
        Assert-AreEqual -Expected "[tag1][tag2] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Add second tag with NO space at the end of tag list
        $string = "[tag1]Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag2"
        Assert-AreEqual -Expected "[tag1][tag2] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Add third tag with no spaces at end of tag list
        $string = "[tag1][tag2]Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag3"
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Add third tag with no spaces at end of tag list
        $string = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag3"
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text" -Presented $string
    }
}

function Test_AddTagString_Already_Exists_KeepStringTheSame{

    Invoke-PrivateContext{

        # Act - Add a tag that already exists on front
        $startString = "[tag1] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $startString -Presented $string

        # Act - Add a tag that already exists not on front
        $startString = "[tag2][tag1] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag2"
        Assert-AreEqual -Expected $startString -Presented $string

        #Act - add a tag that already exists at the end
        $startString = "[tag2] Your string here [other tag to ignore] and after more text [tag1]"
        $string = $startString | Add-TagToString "tag1" -end
        Assert-AreEqual -Expected $startString -Presented $string

        #Act - add a tag that already exists on front in position
        $startString = "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text [tat4][tag5][tag6]"
        $string = $startString | Add-TagToString "tag2" -Position 1
        Assert-AreEqual -Expected $startString -Presented $string

        #Act - add a tag that already exists on end in position
        $startString = "[tat1][tag2][tag3] Your string here [other tag to ignore] and after more text [tat4][tag5][tag6]"
        $string = $startString | Add-TagToString "tag5" -Position 1 -end
        Assert-AreEqual -Expected $startString -Presented $string

    }
}

function Test_AddTagString_Already_Exists_UpdateString{
    
    Invoke-PrivateContext{

        # Act - Add a tag that already exists on front with Spaces
        $startString = "[tag1] [tag2] Your string here [other tag to ignore] and after more text"
        $expectedString = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists on front with Spaces
        $startString = "[tag1][tag2]Your string here [other tag to ignore] and after more text"
        $expectedString = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists on front
        $startString = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $expectedString = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists not on front
        $startString = "[tag2][tag1] Your string here [other tag to ignore] and after more text"
        $expectedString = "[tag2][tag1] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        #Act - add a tag that already exists at the end
        $startString = "[tag2] Your string here [other tag to ignore] and after more text [tag1]"
        $expectedString = "[tag2] Your string here [other tag to ignore] and after more text [tag1]"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists in the middle
        $startString    = "[tag2][tag3] Your string here [other tag to ignore][tag1] and after more text"
        $expectedString = "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1"
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists in the middle
        $startString    = "[tag2][tag3] Your string here [other tag to ignore][tag1] and after more text"
        $expectedString = "[tag2][tag1][tag3] Your string here [other tag to ignore] and after more text"
        $string = $startString | Add-TagToString "tag1" -Position 1
        Assert-AreEqual -Expected $expectedString -Presented $string

        # Act - Add a tag that already exists in the middle
        $startString       = "[tag2][tag3] Your string here [other tag to ignore][tag1] and after more text [tat4][tag5][tag6]"
        $expectedString    = "[tag2][tag3] Your string here [other tag to ignore] and after more text [tat4][tag1][tag5][tag6]"
        $string = $startString | Add-TagToString "tag1" -Position 1 -End
        Assert-AreEqual -Expected $expectedString -Presented $string

    }
}

function Test_AddTagToStringAtPosition{

    Invoke-PrivateContext{

        $startingString = "[tag1][tag2] Your string here [other tag to ignore] and after more text"

        # Act - Position -1
        $string = $startingString | Add-TagToString "tag3" -1
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Position -1 - at the end of the starting list of tags
        $string = $startingString | Add-TagToString "tag3" -1
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Position 0
        $string = $startingString | Add-TagToString "tag3" 0
        Assert-AreEqual -Expected "[tag3][tag1][tag2] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Position 1
        $string = $startingString | Add-TagToString "tag3" 1
        Assert-AreEqual -Expected "[tag1][tag3][tag2] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Position 2
        $string = $startingString | Add-TagToString "tag3" 2
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here [other tag to ignore] and after more text" -Presented $string

    }
}

function Test_AddTagToStringWithPosition_AlreadyThere{

    Invoke-PrivateContext{
        
        # Act - tag exist on same position
        $startingString = "[tag1][tag2][tag3] Your string here and after more text"
        $string = $startingString | Add-TagToString "tag1" 0
        Assert-AreEqual -Expected $startingString -Presented $string
        $string = $startingString | Add-TagToString "tag2" 1
        Assert-AreEqual -Expected $startingString -Presented $string
        $string = $startingString | Add-TagToString "tag3" 2
        Assert-AreEqual -Expected $startingString -Presented $string
        $string = $startingString | Add-TagToString "tag3" -1
        Assert-AreEqual -Expected $startingString -Presented $string

        #Act - tag exist at the end of the string
        $startingString = "[tag1][tag2]Your string here and after more text [tag3]"
        $string = $startingString | Add-TagToString "tag3" 0
        Assert-AreEqual -Expected "[tag3][tag1][tag2] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" 1
        Assert-AreEqual -Expected "[tag1][tag3][tag2] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" 2
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" -1
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here and after more text" -Presented $string

        #Act - tag exist in the middle of the string
        $startingString = "[tag1][tag2]Your string here [tag3] and after more text"
        $string = $startingString | Add-TagToString "tag3" 0
        Assert-AreEqual -Expected "[tag3][tag1][tag2] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" 1
        Assert-AreEqual -Expected "[tag1][tag3][tag2] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" 2
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here and after more text" -Presented $string
        $string = $startingString | Add-TagToString "tag3" -1
        Assert-AreEqual -Expected "[tag1][tag2][tag3] Your string here and after more text" -Presented $string

    }
}

function Test_AddTagToStringWithPosition_AlreadyThere_AddToTheEnd{

    Invoke-PrivateContext{
        
        # Act - tag exist on same position
        $startingString = "[tag1][tag2][tag3] Your string here and after more text"

        $string = $startingString | Add-TagToString -End "tag1" 0
        Assert-AreEqual -Presented $string -Expected "[tag2][tag3] Your string here and after more text [tag1]"
        
        $string = $startingString | Add-TagToString -End "tag2" 1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag3] Your string here and after more text [tag2]"
        
        $string = $startingString | Add-TagToString -End "tag3" 2
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag3]"

        $string = $startingString | Add-TagToString -End "tag3" -1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag3]"

        #Act - tag exist at the end of the string
        $startingString = "[tag1][tag2]Your string here and after more text [tag3]"
        $targetString = "[tag1][tag2] Your string here and after more text [tag3]"

        $string = $startingString | Add-TagToString -End "tag3" 0
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" 1
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" 2
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" -1
        Assert-AreEqual -Presented $string -Expected $targetString

        #Act - tag exist in the middle of the string
        $startingString = "[tag1][tag2]Your string here [tag3] and after more text"
        $targetString = "[tag1][tag2] Your string here and after more text [tag3]"

        $string = $startingString | Add-TagToString -End "tag3" 0
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" 1
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" 2
        Assert-AreEqual -Presented $string -Expected $targetString

        $string = $startingString | Add-TagToString -End "tag3" -1
        Assert-AreEqual -Presented $string -Expected $targetString

    }
}

function Test_AddTagToStringWithPosition_AlreadyThere_AddToTheEnd_With_TailTags{

    Invoke-PrivateContext{
        
        # Act - tag exist on same position
        $startingString = "[tag1][tag2][tag3] Your string here and after more text [tag4][tag5][tag6]"

        $string = $startingString | Add-TagToString -End "tag4" 0
        Assert-AreEqual -Presented $string -Expected $startingString
        
        $string = $startingString | Add-TagToString -End "tag5" 1
        Assert-AreEqual -Presented $string -Expected $startingString
        
        $string = $startingString | Add-TagToString -End "tag6" 2
        Assert-AreEqual -Presented $string -Expected $startingString

        $string = $startingString | Add-TagToString -End "tag6" -1
        Assert-AreEqual -Presented $string -Expected $startingString

        #Act - tag exist at the end of the string
        $startingString = "[tag1][tag2]Your string here and after more text [tag3][tag4][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 0
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag3][tag4][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag3][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 2
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag5][tag3]"

        $string = $startingString | Add-TagToString -End "tag3" -1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag5][tag3]"

        #Act - tag exist in the middle of the string
        $startingString = "[tag1][tag2]Your string here [tag3] and after more text [tag4][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 0
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag3][tag4][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag3][tag5]"

        $string = $startingString | Add-TagToString -End "tag3" 2
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag5][tag3]"

        $string = $startingString | Add-TagToString -End "tag3" -1
        Assert-AreEqual -Presented $string -Expected "[tag1][tag2] Your string here and after more text [tag4][tag5][tag3]"

    }
}

function Test_AddTagToStringEnd{

    Invoke-PrivateContext{

        # Act - Add first tag
        $string = "Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag1" -End
        Assert-AreEqual -Expected "Your string here [other tag to ignore] and after more text [tag1]" -Presented $string

        # Act - Add second tag with space at the end of tag list
        $string = "[tag1] Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag2" -End
        Assert-AreEqual -Expected "[tag1] Your string here [other tag to ignore] and after more text [tag2]" -Presented $string
        
        # Act - Add second tag with NO space at the end of tag list
        $string = "[tag1]Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag2" -End
        Assert-AreEqual -Expected "[tag1] Your string here [other tag to ignore] and after more text [tag2]" -Presented $string
        
        # Act - Add third tag with no spaces at end of tag list
        $string = "[tag1][tag2]Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag3" -End
        Assert-AreEqual -Expected "[tag1][tag2] Your string here [other tag to ignore] and after more text [tag3]" -Presented $string
        
        # Act - Add third tag with no spaces at end of tag list
        $string = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Add-TagToString "tag3" -End
        Assert-AreEqual -Expected "[tag1][tag2] Your string here [other tag to ignore] and after more text [tag3]" -Presented $string
    }

}

function Test_RemoveTagFromString{

    Invoke-PrivateContext{

        # Act - Remove tag from empty string
        $string = ""
        $string = $string | Remove-TagFromString "tag1"
        Assert-AreEqual -Expected "" -Presented $string

        # Act - Remove existing tag
        $string = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Remove-TagFromString "tag1"
        Assert-AreEqual -Expected "[tag2] Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Remove existing tag
        $string = "[tag1][tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Remove-TagFromString "tag2"
        Assert-AreEqual -Expected "[tag1] Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Remove non-existing tag
        $string = "[tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Remove-TagFromString "tag3"
        Assert-AreEqual -Expected "[tag2] Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Remove last tag from front
        $string = "[tag2] Your string here [other tag to ignore] and after more text"
        $string = $string | Remove-TagFromString "tag2"
        Assert-AreEqual -Expected "Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Remove last tag from the middle of the string
        $string = "[tag1] Your string here [tagtarget] and after more text [tag2]"
        $string = $string | Remove-TagFromString "tagtarget"
        Assert-AreEqual -Expected "[tag1] Your string here and after more text [tag2]" -Presented $string

        # Act - Remove tag from the middle of the string
        $string = "[tag1] Your string here [tagtarget][tag4] and after more text [tag3]"
        $string = $string | Remove-TagFromString "tagtarget"
        Assert-AreEqual -Expected "[tag1] Your string here [tag4] and after more text [tag3]" -Presented $string

        # Act - Remove last tag from the back
        $string = "[tag1] Your string here [other tag to ignore] and after more text [tag2]"
        $string = $string | Remove-TagFromString "tag2"
        Assert-AreEqual -Expected "[tag1] Your string here [other tag to ignore] and after more text" -Presented $string

        # Act - Remove tag from the end of the string
        $string = "[tag2] Your string here [other tag to ignore] and after more text [tag3]"
        $string = $string | Remove-TagFromString "tag3"
        Assert-AreEqual -Expected "[tag2] Your string here [other tag to ignore] and after more text" -Presented $string
        
        # Act - Remove tag from the end of the string with several end tags and front tags
        $string = "[tag1][tag2] Your string here [other tag to ignore] and after more text [tag3][tag4]"
        $string = $string | Remove-TagFromString "tag3"
        Assert-AreEqual -Expected "[tag1][tag2] Your string here [other tag to ignore] and after more text [tag4]" -Presented $string
    }
}

function Test_GetTagFromString{
    Invoke-PrivateContext{

        # Act - Get tags from empty string
        $string = ""
        $tags = Get-TagFromString $string
        Assert-Count -Expected 0 -Presented $tags

        # Act - Get single Tag from the front
        $string = "[tag1] Your string here with no other tags"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 1 -Presented $tags
        Assert-AreEqual -Expected "tag1" -Presented $tags[0]

        # Act - Get single tag from the end
        $string = "Your string here with a tag at the end [tagEnd]"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 1 -Presented $tags
        Assert-AreEqual -Expected "tagEnd" -Presented $tags[0]

        # Act - Get tags from the front
        $string = "[tag1][tag2] Your string here with no other tags"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 2 -Presented $tags
        Assert-AreEqual -Expected "tag1" -Presented $tags[0]
        Assert-AreEqual -Expected "tag2" -Presented $tags[1]

        # Act - Get tags from the end
        $string = "Your string here with multiple tags at the end [tag3][tag4]"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 2 -Presented $tags
        Assert-AreEqual -Expected "tag3" -Presented $tags[0]
        Assert-AreEqual -Expected "tag4" -Presented $tags[1]

        # Act - Get tags from the middle
        $string = "Your string here [tagMiddle1] with a tag in the middle [tagMiddle2][tagMiddle3] and more text"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 3 -Presented $tags
        Assert-AreEqual -Expected "tagMiddle1" -Presented $tags[0]
        Assert-AreEqual -Expected "tagMiddle2" -Presented $tags[1]
        Assert-AreEqual -Expected "tagMiddle3" -Presented $tags[2]

        # Act - Get tags from string 
        $string ="[tag1][tag2] some text on the string [tag3][tag4] more text [tag5][tag6]"
        $tags = Get-TagFromString $string
        Assert-Count -Expected 6 -Presented $tags
        Assert-AreEqual -Expected "tag1" -Presented $tags[0]
        Assert-AreEqual -Expected "tag2" -Presented $tags[1]
        Assert-AreEqual -Expected "tag3" -Presented $tags[2]
        Assert-AreEqual -Expected "tag4" -Presented $tags[3]
        Assert-AreEqual -Expected "tag5" -Presented $tags[4]
        Assert-AreEqual -Expected "tag6" -Presented $tags[5]

    }
}

function Test_GetTagValue{
    Invoke-PrivateContext{

        # Act - Get Tag value
        $string = "[tag1:Value1] Value for tag1 [tag2][tag3:Value3] Value for tag2"
        $value = Get-TagValue -String $string -Tag "tag1"
        Assert-AreEqual -Expected "Value1" -Presented $value

        # Act - Get Tag value for a tag without a value
        $string = "[tag1:Value1] Value for tag1 [tag2][tag3:Value3] Value for tag2"
        $value = Get-TagValue -String $string -Tag "tag2"
        Assert-IsNull -Object $value

        # Act - Get Tag value for another tag with a value
        $string = "[tag1:Value1] Value for tag1 [tag2][tag3:Value3] Value for tag2"
        $value = Get-TagValue -String $string -Tag "tag3"
        Assert-AreEqual -Expected "Value3" -Presented $value

    }
}

function Test_TestTagOnString{
    Invoke-PrivateContext{

        # Partial match
        $result = Test-TagOnString -String "[tag1][other] Text" -Tag "tag"
        Assert-IsTrue -Condition ($result -is [bool])
        Assert-IsTrue -Condition $result

        # Exact match
        $result = Test-TagOnString -String "[tag1][other] Text" -Tag "tag1" -Exact
        Assert-IsTrue -Condition ($result -is [bool])
        Assert-IsTrue -Condition $result

        # Partial match does not satisfy exact matching
        $result = Test-TagOnString -String "[tag1][other] Text" -Tag "tag" -Exact
        Assert-IsFalse -Condition $result

        # Missing tag
        $result = Test-TagOnString -String "[tag1][other] Text" -Tag "missing"
        Assert-IsFalse -Condition $result

        # Empty string
        $result = Test-TagOnString -String "" -Tag "tag"
        Assert-IsFalse -Condition $result

        # Pipeline input
        $result = "[tag1][other] Text" | Test-TagOnString -Tag "other" -Exact
        Assert-IsTrue -Condition $result
    }
}