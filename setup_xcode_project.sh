#!/bin/bash

# Setup script for ClockedOut macOS App
# This script helps create an Xcode project for the app

echo "🚀 Setting up ClockedOut Xcode Project..."
echo ""

# Check if xcodegen is installed
if command -v xcodegen &> /dev/null; then
    echo "✅ XcodeGen found. Generating project..."
    xcodegen generate
    echo ""
    echo "✅ Project generated! Opening in Xcode..."
    open ClockedOut.xcodeproj
else
    echo "❌ XcodeGen not found."
    echo ""
    echo "Please choose one of these options:"
    echo ""
    echo "Option 1: Install XcodeGen and run this script again"
    echo "  brew install xcodegen"
    echo "  ./setup_xcode_project.sh"
    echo ""
    echo "Option 2: Create project manually in Xcode"
    echo "  1. Open Xcode"
    echo "  2. File > New > Project"
    echo "  3. Choose macOS > App"
    echo "  4. Name: ClockedOut"
    echo "  5. Add GRDB package: File > Add Package Dependencies"
    echo "     URL: https://github.com/groue/GRDB.swift"
    echo "  6. Copy all files from ClockedOut/ folder into the project"
    echo ""
    echo "See BUILD_INSTRUCTIONS.md for detailed steps."
fi

