#!/bin/bash

# Function to check if a string contains any illegal characters
containsIllegalCharacters() {
    local theString="$1"
    local illegalCharacters="[\\/:*?\"<>|]" # List of illegal characters
    
    # Check if the string contains any illegal characters
    if [[ $theString =~ $illegalCharacters ]]; then
        return 0 # Contains illegal characters
    else
        return 1 # Does not contain illegal characters
    fi
}

# Function to remove leading and trailing spaces from a string
trimString() {
    local theString="$1"
    local trimmedString=${theString%% }
    trimmedString=${trimmedString## }
    echo "$trimmedString"
}

# Function to check and correct file names
checkAndCorrectNames() {
    local baseFolder="$1"
    local reportFile="$2"
    
    # Loop through all items in the base folder
    while IFS= read -r -d '' theItem; do
        itemName=$(basename "$theItem")
        newPath=$(dirname "$theItem")/$(trimString "$itemName")
        
        # Check if the item is a file and has illegal characters or overlong path name
        if [[ -f "$theItem" && ( $(containsIllegalCharacters "$itemName") == 0 || ${#newPath} -gt 255 ) ]]; then
            # Write the item to the report file
            printf "Old: %s\n" "$itemName" >> "$reportFile"
            printf "New: %s\n\n" "$newPath" >> "$reportFile"
        fi
    done < <(find "$baseFolder" -type f -print0)
}

# Main script
read -rp "Enter the folder path to check and correct names: " givenPath

# Check if the given path is a valid folder
if [[ -d "$givenPath" ]]; then
    reportFile="/tmp/report.txt"
    rm -f "$reportFile"
    
    checkAndCorrectNames "$givenPath" "$reportFile"
    
    # Display the report
    if [[ -s "$reportFile" ]]; then
        printf "Proposed changes:\n\n"
        cat "$reportFile"
        printf "\n"
        
        read -rp "Do you want to rename the files? (y/n): " choice
        if [[ $choice == [Yy] ]]; then
            # Rename the files
            while IFS= read -r -d '' theItem; do
                itemName=$(basename "$theItem")
                newPath=$(dirname "$theItem")/$(trimString "$itemName")
                mv "$theItem" "$newPath"
            done < <(grep -e '^Old: ' "$reportFile" | awk '{print $2}')
            
            printf "\nRenaming completed.\n"
        else
            printf "\nRenaming cancelled.\n"
        fi
    else
        printf "No changes required.\n"
    fi
    
    rm -f "$reportFile"
else
    printf "Invalid folder path.\n"
fi
