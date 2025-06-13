#!/bin/bash

set -euo pipefail

APP_NAME="cupcake"
SCHEME="cupcake"
PROJECT_PATH="src/cupcake.xcodeproj"
BUILD_DIR="build"
ZIP_NAME="${APP_NAME}.zip"
VERSION="1.0.0"
REPO_SLUG="wizenheimer/cupcake"
TAP_REPO="wizenheimer/homebrew-cupcake"
CASK_PATH="Casks/${APP_NAME}.rb"

echo "Cleaning old build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Building .app with xcodebuild..."
xcodebuild -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  -quiet

APP_PATH=$(find "$BUILD_DIR/DerivedData" -type d -name "${APP_NAME}.app" | head -n 1)

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: .app not found in DerivedData"
  exit 1
fi

echo "Copying built .app to $BUILD_DIR/"
cp -R "$APP_PATH" "$BUILD_DIR/"

echo "Zipping app..."
ditto -c -k --sequesterRsrc --keepParent "$BUILD_DIR/${APP_NAME}.app" "$BUILD_DIR/$ZIP_NAME"

echo "Calculating SHA256..."
SHA=$(shasum -a 256 "$BUILD_DIR/$ZIP_NAME" | awk '{print $1}')
echo "SHA256: $SHA"

echo "📄 Writing Homebrew Cask to $CASK_PATH..."
mkdir -p "$(dirname $CASK_PATH)"
cat > "$CASK_PATH" <<EOF
cask "${APP_NAME}" do
  version "${VERSION}"
  sha256 "${SHA}"

  url "https://github.com/${REPO_SLUG}/releases/download/v\#{version}/${ZIP_NAME}"
  name "Cupcake"
  desc "Dock cat animation app — unsigned"
  homepage "https://github.com/${REPO_SLUG}"

  app "${APP_NAME}.app"

  caveats <<~EOS
    This app is not signed or notarized.
    To open it the first time:
      1. Right-click the app in Finder
      2. Click "Open"
      3. Confirm the dialog
  EOS
end
EOF

echo "Done!"
echo "1. Go to https://github.com/${REPO_SLUG}/releases/new"
echo "2. Tag: v${VERSION}"
echo "3. Upload: build/${ZIP_NAME}"
echo "4. Commit ${CASK_PATH} to your tap: ${TAP_REPO}"
