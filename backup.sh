#!/bin/bash

# Update if required.
clean_path=/mnt/c/Users/Nicho/Desktop/

declare -a folders=("zip" "gz" "rar" "sitz" "7z")
# Additionally, default folder types for folders
declare -a images=("png" "jpeg" "jpg" "psd" "ai" "gif" "eps" "tiff" "bmp")
declare -a videos=("mp4" "mov" "wmv" "flv" "avi" "avchd" "flv" "m2v")
declare -a audio=("mp3" "wav" "mpc" "m4a" "m4b" "m4p" "mmf")
declare -a txt=("txt" "md")
declare -a word=("docx" "dot" "dotx" "eml")
declare -a pptx=("pptx" "pptm" "ppt")
declare -a excel=("xlsx" "xlsm" "xlsb" "xltx")
declare -a pdf=("pdf")
declare -a scripts=("sh")
declare -a data=("json" "yaml" "yml")
declare -a shortcuts=("lnk" "url")
declare -a exe=("exe")
declare -a binary=("bin")
# Additionally, default binary file types for binary

# New Folder which things will be cleaned to
# Changing this will impact current regex and future sorts
clean_folder="Backup $(date '+%Y-%m-%d')"
clean_regex="^[a-zA-Z]+ [0-9]{4}-[0-9]{2}-[0-9]{2}$"

# Check Path is valid
echo "[+] Checking Path is Valid"
if command cd $clean_path >/dev/null 2>&1 ; then
    echo "[-] Path Found!"
else
    echo "[-] Path not found! Aborting..."
    echo "[-] Please check directory path in script is correct and try again."
    exit 0
fi

# Ask user to confirm that they want to clean
read -p "[+] Clean ${clean_path} with $(ls | wc -l) entities? (Enter 'y' or 'n') " clean
if [[ $clean = 'y' ]]; then
    echo "[-] Accessing ${clean_path}"
    cd $clean_path
else
    echo "[-] Aborting..."
    exit 0
fi

# Ask user to confirm if they want an other folder
read -p "[+] Create 'other' folder for left unknown types? (Enter 'y' or 'n') " other_folder
if [[ $other_folder = 'y' ]]; then
    echo "[-] 'other' folder will be created"
else
    echo "[-] 'other' folder will not be created"
fi

# Create Cleanup Folder
if command mkdir "${clean_folder}" >/dev/null 2>&1 ; then
    echo "[-] Successfully Created Backup Folder"
else
    echo "[-] Backup has already been completed today! Appending to previously created folder..."
fi


# Move Function
move () {
    mkdir -p "${clean_folder}/${2}"
    mv "$1" "${clean_folder}/${2}"
}

# Sort Files
echo "[+] Starting to sort"
for f in $PWD/*
do
    echo "[-] Sorting ${f##*/}"

    # Get file extension to categories
    file_ext=${f##*.}

    # Lowercase file extension for png/PNG differences
    ext=${file_ext,,}

    # Sort in folders
    if [[ -d $f || "${folders[*]}" =~  "$ext" ]]; then

        # Check if folder is a backup folder.
        # Will do nothing to this file
        if [[ ${f##*/} =~ $clean_regex ]]; then
            echo "${f##*/} is a Backup"
            continue
        else
            move "${f##*/}" "folders"
        fi

    # Sort in images
    elif [[ "${images[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "images"
    
    # Sort in videos
    elif [[ "${videos[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "videos"
    
    # Sort in audio
    elif [[ "${audio[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "audio"

    # Sort in txt
    elif [[ "${txt[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "txt"

    # Sort in word
    elif [[ "${word[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "word"

    # Sort in pptx
    elif [[ "${pptx[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "pptx"

    # Sort in excel
    elif [[ "${excel[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "excel"

    # Sort in pdf
    elif [[ "${pdf[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "pdf"
    
    # Sort in scripts
    elif [[ "${scripts[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "scripts"
        continue

    # Sort in data
    elif [[ "${data[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "data"
        continue

    # Sort in shortcuts
    elif [[ "${shortcuts[*]}" =~ "$ext" ]]; then
        echo "${f##*/} is a shortcut. I am not moving this."
        continue
    
    # Sort in exe
    elif [[ "${exe[*]}" =~ "$ext" ]]; then
        echo "${f##*/} is an executable. I am not moving this."
        continue

    # Sort in binaries
    elif [[ "${binary[*]}" =~ "$ext" ]]; then
        move "${f##*/}" "binaries"

    # Sort in binaries (default application files)
    elif command file -b --mime-type "${f##*/}" | sed 's|/.*||' 2>&1 ; then
        move "${f##*/}" "binaries"

    # Sort in other if enabled
    elif [[ $other_folder = 'y' ]]; then
        move "${f##*/}" "other"
    fi
done
