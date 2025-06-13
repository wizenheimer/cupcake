#!/bin/bash

set -euo pipefail

# Configuration
APP_NAME="cupcake"
REPO_SLUG="wizenheimer/cupcake"
TAP_REPO="wizenheimer/homebrew-cupcake"
CASK_FILE="dist/${APP_NAME}.rb"

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <version> [tap_directory]"
    echo "Examples:"
    echo "  $0 1.0.2                           # Uses ../homebrew-cupcake"
    echo "  $0 1.0.2 ~/repos/homebrew-cupcake  # Uses custom path"
    echo ""
    echo "Make sure you've already:"
    echo "1. Run ./distribute.sh <version>"
    echo "2. Created the GitHub release"
    echo "3. Uploaded the zip file to the release"
    exit 1
fi

VERSION="$1"
TAP_DIR="${2:-../homebrew-cupcake}"  # Use second argument or default

# Validate version format
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.0.2)"
    exit 1
fi

echo "Updating Homebrew tap for version $VERSION..."
echo "Using tap directory: $TAP_DIR"

# Check if the cask file exists
if [[ ! -f "$CASK_FILE" ]]; then
    echo "Error: $CASK_FILE not found!"
    echo "Run ./distribute.sh $VERSION first"
    exit 1
fi

# Check if tap directory exists, clone if not
if [[ ! -d "$TAP_DIR" ]]; then
    echo "Cloning tap repository..."
    git clone "https://github.com/${TAP_REPO}.git" "$TAP_DIR"
fi

# Navigate to tap directory
cd "$TAP_DIR"

echo "Updating tap repository..."
git pull origin main

# Create Casks directory if it doesn't exist
mkdir -p Casks

# Copy the new cask file
echo "Copying new cask file..."
cp "../cupcake/$CASK_FILE" "Casks/${APP_NAME}.rb"

# Verify the cask file is valid
echo "Validating cask file..."
if ! brew style "Casks/${APP_NAME}.rb"; then
    echo "Cask file has style issues, but continuing..."
fi

# Check if there are changes to commit
if git diff --quiet; then
    echo "No changes detected in cask file"
    exit 0
fi

echo "Committing changes..."
git add "Casks/${APP_NAME}.rb"
git commit -m "Update ${APP_NAME} to version ${VERSION}"

echo "Pushing to GitHub..."
git push origin main

echo "Done! Homebrew tap updated successfully"
echo ""
echo "Users can now install with:"
echo "  brew tap ${TAP_REPO}"
echo "  brew install --cask ${APP_NAME}"
echo ""
echo "Or update existing installations with:"
echo "  brew upgrade --cask ${APP_NAME}"