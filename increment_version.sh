#!/bin/bash

# Path to pubspec.yaml
FILE="pubspec.yaml"

# Check if the pubspec.yaml file exists
if [ ! -f "$FILE" ]; then
  echo "pubspec.yaml not found in the current directory."
  exit 1
fi

# Read the current version line
VERSION_LINE=$(grep 'version:' $FILE)

# Extract current version and build numbers using sed
CURRENT_VERSION=$(echo $VERSION_LINE | sed -E 's/version: ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)/\1/')
CURRENT_BUILD=$(echo $VERSION_LINE | sed -E 's/version: ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)/\2/')

# Increment the patch and build numbers
IFS='.' read -ra ADDR <<< "$CURRENT_VERSION"
MAJOR=${ADDR[0]}
MINOR=${ADDR[1]}
PATCH=${ADDR[2]}
let PATCH+=1
let CURRENT_BUILD+=1

# Compose new version string
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$CURRENT_BUILD"

# Determine if the system is macOS or Linux for correct sed usage
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS system
  sed -i '' "s/version: .*/version: $NEW_VERSION/" $FILE
else
  # Linux system
  sed -i "s/version: .*/version: $NEW_VERSION/" $FILE
fi

# Output the updated version
echo "Updated version: $NEW_VERSION"
