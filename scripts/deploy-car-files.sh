#!/bin/bash

TARGET_DIR=$1

if [ -z "$TARGET_DIR" ]; then
    echo "Target directory not provided!"
    exit 1
fi

folders=("CRM" "ERS" "Enterprise-Services" "HR-Finance" "Membership" "Travel" "Utilities" "LMS")

for folder in "${folders[@]}"; do
    version_file="$folder/version.yaml"
    if [ ! -f "$version_file" ]; then
        echo "Skipping $folder, version file not found."
        continue
    fi

    version=$(grep 'version:' "$version_file" | awk '{print $2}')
    echo "Deploying $folder .car files, version $version"

    # Copy all .car files to target directory (replacing existing ones)
    for file in "$folder"/*.car; do
        if [ -f "$file" ]; then
            cp -f "$file" "$TARGET_DIR/"
            echo "Copied $(basename "$file") to $TARGET_DIR"
        fi
    done
done

