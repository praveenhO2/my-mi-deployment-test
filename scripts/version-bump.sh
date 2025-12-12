#!/bin/bash

folders=("CRM" "ERS" "Enterprise-Services" "HR-Finance" "Membership" "Travel" "Utilities" "LMS")

echo "Checking which folders have .car changes..."

for folder in "${folders[@]}"; do
    version_file="$folder/version.yaml"
    echo ""
    echo "---------------------------------------"
    echo "Processing folder: $folder"
    echo "---------------------------------------"

    # Detect .car changes
    changed_files=$(git diff --name-only HEAD^ HEAD -- "$folder"/*.car || true)

    if [ -z "$changed_files" ]; then
        echo "No .car changes detected in $folder. Skipping."
        continue
    fi

    echo "Detected changed .car files:"
    echo "$changed_files"

    # Create version.yaml if missing
    if [ ! -f "$version_file" ]; then
        echo "version: 1.0.0" > "$version_file"
        echo "Created new version file for $folder with version 1.0.0"
    fi

    # Read current version
    current_version=$(grep 'version:' "$version_file" | awk '{print $2}')
    echo "Current version for $folder: $current_version"

    # Split version
    IFS='.' read -r major minor patch <<< "$current_version"

    # Increment version (patch first, rollover to minor)
    patch=$((patch + 1))
    if [ "$patch" -gt 99 ]; then
        patch=0
        minor=$((minor + 1))
    fi

    new_version="${major}.${minor}.${patch}"
    echo "Updating version to: $new_version"

    echo "version: $new_version" > "$version_file"
    git add "$version_file"
done

# Commit changes if any
if git diff --cached --quiet; then
    echo "No version changes to commit. Exiting."
    exit 0
fi

git config user.name "github-actions"
git config user.email "actions@github.com"
git commit -m "Auto version bump for updated .car files"
git push origin main

