# Building ClockedOut as a macOS Application

## Option 1: Using XcodeGen (Recommended)

1. **Install XcodeGen** (if not already installed):
   ```bash
   brew install xcodegen
   ```

2. **Generate the Xcode project**:
   ```bash
   cd "/Users/udivak/Self Projects/ClockedOut"
   xcodegen generate
   ```

3. **Open the project in Xcode**:
   ```bash
   open ClockedOut.xcodeproj
   ```

4. **Build and Run**:
   - In Xcode, select the "ClockedOut" scheme
   - Press `Cmd+R` to build and run
   - The app will launch and you can start using it!

## Option 2: Create Xcode Project Manually

1. **Open Xcode** and select "Create a new Xcode project"

2. **Choose macOS > App** and click Next

3. **Configure the project**:
   - Product Name: `ClockedOut`
   - Team: Your development team
   - Organization Identifier: `com.clockedout`
   - Bundle Identifier: `com.clockedout.ClockedOut`
   - Language: Swift
   - Interface: SwiftUI
   - Storage: None
   - Minimum Deployment: macOS 13.0

4. **Add GRDB dependency**:
   - In Xcode, go to File > Add Package Dependencies
   - Enter: `https://github.com/groue/GRDB.swift`
   - Select version 6.0.0 or later
   - Add to target: ClockedOut

5. **Copy all source files**:
   - Copy all files from the `ClockedOut/` directory into your Xcode project
   - Make sure they're added to the ClockedOut target

6. **Build and Run**:
   - Press `Cmd+R` to build and run

## Option 3: Using Swift Package Manager (for development)

If you just want to test the code without creating an app bundle:

```bash
cd "/Users/udivak/Self Projects/ClockedOut"
swift build
```

However, this won't create a `.app` file - you'll need Xcode for that.

## Creating a Distributable App

Once you've built the app in Xcode:

1. **Archive the app**:
   - In Xcode: Product > Archive
   - Wait for the archive to complete

2. **Export the app**:
   - In the Organizer window, select your archive
   - Click "Distribute App"
   - Choose "Copy App" to create a standalone `.app` file
   - Save it to your desired location

3. **The `.app` file** can now be:
   - Moved to `/Applications` folder
   - Distributed to other Macs
   - Run by double-clicking

## Troubleshooting

- **If you get import errors**: Make sure GRDB is added as a dependency
- **If the app crashes on launch**: Check the Console app for error messages
- **Database location**: The database is stored in `~/Library/Application Support/ClockedOut/`

