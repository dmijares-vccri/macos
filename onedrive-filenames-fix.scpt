-- how to use osascript scriptname.scpt /path/to/folder

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
on checkAndCorrectNames(baseFolder)
    tell application "Finder"
        set itemList to every item of baseFolder
        
        repeat with theItem in itemList
            set itemName to name of theItem
            set newPath to (POSIX path of (container of theItem as alias)) & trimString(itemName)
            
            -- Check if the item has illegal characters or overlong path name
            if containsIllegalCharacters(itemName) or length of newPath > 255 then
                -- Correct the item's name by removing illegal characters and overlong path name
                set name of theItem to newPath
            end if
            
            -- Check if the item is a folder
            if class of theItem is folder then
                -- Recursively check and correct names in subfolders
                checkAndCorrectNames(theItem)
            end if
        end repeat
    end tell
end checkAndCorrectNames

-- Main script
on run argv
    set givenPath to item 1 of argv
    
    tell application "Finder"
        -- Check if the given path is a valid folder
        if exists folder givenPath then
            set baseFolder to folder givenPath
            checkAndCorrectNames(baseFolder)
        else
            display dialog "Invalid folder path."
        end if
    end tell
end run
