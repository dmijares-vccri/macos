-- Function to check if a string contains any illegal characters
on containsIllegalCharacters(theString)
    set illegalCharacters to "[\\/:*?\"<>|]" -- List of illegal characters
    
    -- Check if the string contains any illegal characters
    considering case
        if theString contains characters of illegalCharacters then
            return true
        else
            return false
        end if
    end considering
end containsIllegalCharacters

-- Function to remove leading and trailing spaces from a string
on trimString(theString)
    set trimmedString to theString
    set beginningTrimmed to true
    set endingTrimmed to true
    
    -- Remove leading spaces
    repeat while beginningTrimmed
        considering case
            if (text 1 of trimmedString) is equal to " " then
                set trimmedString to text 2 thru -1 of trimmedString
            else
                set beginningTrimmed to false
            end if
        end considering
    end repeat
    
    -- Remove trailing spaces
    repeat while endingTrimmed
        considering case
            if (text -1 of trimmedString) is equal to " " then
                set trimmedString to text 1 thru -2 of trimmedString
            else
                set endingTrimmed to false
            end if
        end considering
    end repeat
    
    return trimmedString
end trimString

-- Function to check and correct file or folder names
on checkAndCorrectNames(baseFolder, reportList)
    tell application "Finder"
        set itemList to every item of baseFolder
        
        repeat with theItem in itemList
            set itemName to name of theItem
            set newPath to (POSIX path of (container of theItem as alias)) & trimString(itemName)
            
            -- Check if the item has illegal characters or overlong path name
            if containsIllegalCharacters(itemName) or length of newPath > 255 then
                -- Add the item to the report list
                set end of reportList to {oldName:itemName, newName:newPath}
            end if
            
            -- Check if the item is a folder
            if class of theItem is folder then
                -- Recursively check and correct names in subfolders
                checkAndCorrectNames(theItem, reportList)
            end if
        end repeat
    end tell
end checkAndCorrectNames

-- Main script
on run argv
    set givenPath to item 1 of argv
    set reportList to {}
    
    tell application "Finder"
        -- Check if the given path is a valid folder
        if exists folder givenPath then
            set baseFolder to folder givenPath
            checkAndCorrectNames(baseFolder, reportList)
            
            -- Generate the report
            set reportText to "Proposed changes:\n"
            repeat with itemData in reportList
                set oldName to oldName of itemData
                set newName to newName of itemData
                set reportText to reportText & "Old: " & oldName & "\n"
                set reportText to reportText & "New: " & newName & "\n\n"
            end repeat
            
            -- Display the report
            display dialog reportText with icon note buttons {"Cancel", "Rename"} default button "Rename"
            if button returned of result is "Rename" then
                -- Rename the files and folders
                repeat with itemData in reportList
                    set oldName to oldName of itemData
                    set newName to newName of itemData
                    set targetItem to item oldName of baseFolder
                    set name of targetItem to newName
                end repeat
                display dialog "Renaming completed." with icon note buttons {"OK"} default button "OK"
            end if
        else
            display dialog "Invalid folder path."
        end if
    end tell
end run
