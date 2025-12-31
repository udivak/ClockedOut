# Quick Start Guide - Making ClockedOut a macOS App

## Fastest Way (if you have Homebrew):

```bash
# 1. Install XcodeGen
brew install xcodegen

# 2. Generate the Xcode project
cd "/Users/udivak/Self Projects/ClockedOut"
./setup_xcode_project.sh

# 3. The project will open in Xcode automatically
# 4. Press Cmd+R to build and run!
```

## Manual Way (no extra tools needed):

1. **Open Xcode** (make sure you have Xcode installed from the App Store)

2. **Create New Project**:
   - File > New > Project (or Cmd+Shift+N)
   - Select **macOS** tab
   - Choose **App**
   - Click **Next**

3. **Configure Project**:
   - Product Name: `ClockedOut`
   - Team: Select your Apple ID/Team
   - Organization Identifier: `com.clockedout`
   - Bundle Identifier: Will auto-fill as `com.clockedout.ClockedOut`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (we use our own database)
   - Minimum Deployment: **macOS 13.0**
   - Click **Next**

4. **Save Location**:
   - Choose a location (or use the current folder)
   - Click **Create**

5. **Add GRDB Dependency**:
   - In Xcode: File > Add Package Dependencies...
   - Paste this URL: `https://github.com/groue/GRDB.swift`
   - Click **Add Package**
   - Select version **6.0.0** or later
   - Make sure **ClockedOut** target is checked
   - Click **Add Package**

6. **Replace Default Files**:
   - Delete the default `ContentView.swift` and `ClockedOutApp.swift` that Xcode created
   - In Finder, copy ALL files from the `ClockedOut/` folder in your project directory
   - Drag them into Xcode's project navigator (left sidebar)
   - Make sure "Copy items if needed" is checked
   - Make sure "ClockedOut" target is checked
   - Click **Finish**

7. **Build and Run**:
   - Press **Cmd+R** or click the Play button
   - The app will compile and launch!

## Your App is Ready! 🎉

Once built, you can:
- **Run it**: Press Cmd+R in Xcode
- **Find the .app**: Right-click on "ClockedOut" scheme > Show in Finder
- **Move to Applications**: Drag the .app file to your Applications folder
- **Run anytime**: Double-click the app in Applications

## First Time Setup:

1. Launch the app
2. Go to **Settings** tab
3. Set your **Weekday Rate** and **Weekend Rate**
4. Go to **Import** tab
5. Import your CSV file (drag & drop or click Browse)

That's it! Your time tracking reports are ready.

