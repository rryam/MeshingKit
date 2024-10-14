#!/bin/bash

set -e
set -x  # Add debug output to help troubleshoot CI issues

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/build"}"
XCODEBUILD_BUILD_DIR="$PROJECT_BUILD_DIR/xcodebuild"
XCODEBUILD_DERIVED_DATA_PATH="$XCODEBUILD_BUILD_DIR/DerivedData"

# Ensure build directories exist and have correct permissions
mkdir -p "$PROJECT_BUILD_DIR"
mkdir -p "$XCODEBUILD_BUILD_DIR"
mkdir -p "$XCODEBUILD_DERIVED_DATA_PATH"
chmod -R 755 "$PROJECT_BUILD_DIR"

PACKAGE_NAME=$1
if [ -z "$PACKAGE_NAME" ]; then
    echo "No package name provided. Using the first scheme found in the Package.swift."
    PACKAGE_NAME=$(xcodebuild -list | awk 'schemes && NF>0 { print $1; exit } /Schemes:$/ { schemes = 1 }')
    echo "Using: $PACKAGE_NAME"
fi

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"

    local XCODEBUILD_ARCHIVE_PATH="$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive"

    rm -rf "$XCODEBUILD_ARCHIVE_PATH"

    xcodebuild archive \
        -scheme $scheme \
        -archivePath "$XCODEBUILD_ARCHIVE_PATH" \
        -derivedDataPath "$XCODEBUILD_DERIVED_DATA_PATH" \
        -sdk "$sdk" \
        -destination "$destination" \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        SKIP_INSTALL=NO \
        INSTALL_PATH='Library/Frameworks' \
        OTHER_SWIFT_FLAGS=-no-verify-emitted-module-interface

    # Check if archive was created successfully
    if [ ! -d "$XCODEBUILD_ARCHIVE_PATH" ]; then
        echo "Error: Archive was not created at $XCODEBUILD_ARCHIVE_PATH"
        exit 1
    fi

    FRAMEWORK_MODULES_PATH="$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Modules"
    mkdir -p "$FRAMEWORK_MODULES_PATH"
    
    SWIFT_MODULE_SOURCE="$XCODEBUILD_DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/Release-$sdk/$scheme.swiftmodule"
    if [ ! -d "$SWIFT_MODULE_SOURCE" ]; then
        echo "Error: Swift module not found at $SWIFT_MODULE_SOURCE"
        exit 1
    fi
    
    cp -r "$SWIFT_MODULE_SOURCE" "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"
    
    # Delete private swiftinterface
    find "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule" -name "*.private.swiftinterface" -delete
    
    # Ensure correct permissions
    chmod -R 755 "$XCODEBUILD_ARCHIVE_PATH"
}

sed -i '' 's/type: \.static/type: .dynamic/g' Package.swift

build_framework "iphonesimulator" "generic/platform=iOS Simulator" "$PACKAGE_NAME"
build_framework "iphoneos" "generic/platform=iOS" "$PACKAGE_NAME"

echo "Builds completed successfully."

XCFRAMEWORK_PATH="$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"
rm -rf "$XCFRAMEWORK_PATH"

# Use full paths for xcframework creation
xcodebuild -create-xcframework \
    -framework "$PROJECT_BUILD_DIR/$PACKAGE_NAME-iphonesimulator.xcarchive/Products/Library/Frameworks/$PACKAGE_NAME.framework" \
    -framework "$PROJECT_BUILD_DIR/$PACKAGE_NAME-iphoneos.xcarchive/Products/Library/Frameworks/$PACKAGE_NAME.framework" \
    -output "$XCFRAMEWORK_PATH"

# Copy dSYMs with full paths
mkdir -p "$XCFRAMEWORK_PATH/ios-arm64_x86_64-simulator"
mkdir -p "$XCFRAMEWORK_PATH/ios-arm64"
cp -r "$PROJECT_BUILD_DIR/$PACKAGE_NAME-iphonesimulator.xcarchive/dSYMs" "$XCFRAMEWORK_PATH/ios-arm64_x86_64-simulator"
cp -r "$PROJECT_BUILD_DIR/$PACKAGE_NAME-iphoneos.xcarchive/dSYMs" "$XCFRAMEWORK_PATH/ios-arm64"

# Zip the xcframework
zip -r "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework.zip" "$XCFRAMEWORK_PATH"

# Ensure correct permissions for the final xcframework
chmod -R 755 "$XCFRAMEWORK_PATH"
