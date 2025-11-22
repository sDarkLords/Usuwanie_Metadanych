#!/bin/bash

# Script for removing metadata from files

# Checking if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    sudo apt update && sudo apt install -y libimage-exiftool-perl || {
        echo "Error: Failed to install exiftool"
        exit 1
    }
fi

# Checking whether an argument has been provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file> [<next_file> ]"
    echo "Example: $0 photo.jpg document.pdf"
    exit 1
fi

# Loop processing all arguments (files) passed to the script
for file in "$@"; do
    # Check if the file exists and is a regular file
    if [ ! -f "$file" ]; then
        echo "Warning: File ‘$file’ does not exist - skipping"
        continue
    fi
    
    # Information about the start of processing the current file
    echo "Przetwarzam plik: $file"
    
    # Creating a backup
    backup="${file}.backup"
    cp "$file" "$backup"
    echo "Backup created: $backup"
    
    # Use exiftool with the -all= option to remove all metadata
    exiftool -all= "$file" -overwrite_original
    
    # Checking the status of the last command 
    if [ $? -eq 0 ]; then
        echo "Metadata has been removed from the file: $file"
        
        # File size comparisons
        original_size=$(stat -c %s "$backup")
        new_size=$(stat -c %s "$file")
        size_diff=$((original_size - new_size))
        
        # Displaying information about saved space
        echo "Space saved: $size_diff bytes"
    else
        # If an error occurred 
        echo "Error: Failed to remove metadata from file: $file"
        echo "I am restoring the original file from the backup copy."
        # Restoring the original version of a file from a backup 
        mv "$backup" "$file"
    fi
done

echo "Operation complete."
