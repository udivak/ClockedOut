# ClockedOut ⏰

A native macOS application for tracking and analyzing time entries from CSV reports. ClockedOut helps you import time tracking data, calculate weekday and weekend hours, and generate comprehensive reports with salary calculations.

## ✨ Features

- **📥 CSV Import** - Import time tracking CSV files with drag-and-drop support
- **📊 Time Analysis** - Automatically calculates weekday (Sunday-Thursday) and weekend (Friday-Saturday) hours
- **📈 Weekly Reports** - Generate detailed weekly breakdown reports
- **💰 Salary Calculations** - Store monthly summaries with automatic salary calculations based on hourly rates
- **💾 Persistent Storage** - SQLite database for reliable data storage
- **📤 Export Reports** - Export reports to PDF and CSV formats
- **⚙️ Customizable Rates** - Set different hourly rates for weekdays and weekends
- **🎨 Modern UI** - Beautiful SwiftUI interface with native macOS design

## 📋 Requirements

- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later (for building from source)
- **Swift** 5.9 or later

## 🚀 Quick Start

### Option 1: Using XcodeGen (Recommended)

The fastest way to get started:

```bash
# Install XcodeGen (if not already installed)
brew install xcodegen

# Generate and open the Xcode project
./setup_xcode_project.sh

# Build and run in Xcode (Cmd+R)
```

### Option 2: Manual Setup

1. **Open Xcode** and create a new macOS App project
2. **Configure**:
   - Product Name: `ClockedOut`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: macOS 13.0
3. **Add GRDB dependency**:
   - File > Add Package Dependencies
   - URL: `https://github.com/groue/GRDB.swift`
   - Version: 6.0.0 or later
4. **Copy source files** from `ClockedOut/` directory
5. **Build and Run** (Cmd+R)

📖 **For detailed step-by-step instructions, see [QUICK_START.md](QUICK_START.md)**

## 🎯 Usage

### First Time Setup

1. **Launch the app** - Build and run in Xcode, or open the `.app` file
2. **Configure rates** - Go to the **Settings** tab and set your:
   - Weekday Rate (Sunday-Thursday)
   - Weekend Rate (Friday-Saturday)
3. **Import data** - Navigate to the **Import** tab and:
   - Drag and drop your CSV file, or
   - Click "Browse" to select a file

### Using the App

#### Import Tab
- Import CSV files containing time tracking data
- The app automatically parses and validates entries
- Duplicate entries are detected and handled

#### Reports Tab
- View monthly summaries with total hours and salary
- Browse weekly breakdown reports
- See detailed statistics for each week
- Export reports to PDF or CSV

#### Settings Tab
- Configure hourly rates for weekdays and weekends
- Settings are automatically saved and applied to calculations

## 🏗️ Architecture

ClockedOut follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **SwiftUI** - Modern declarative UI framework
- **GRDB** - Type-safe SQLite wrapper for database operations
- **Modern Swift Concurrency** - async/await for asynchronous operations
- **Combine** - Reactive data flow and state management

### Key Components

- **Models** - Data structures (`TimeEntry`, `MonthlySummary`, `WeeklySummary`)
- **Views** - SwiftUI views (`ContentView`, `ImportView`, `ReportView`, `SettingsView`)
- **ViewModels** - Business logic and state management
- **Services** - Core functionality (parsing, calculation, export)
- **Database** - SQLite persistence layer with migrations
- **Utilities** - Helpers for formatting, validation, and logging

## 📁 Project Structure

```
ClockedOut/
├── ClockedOut/                    # Main source code
│   ├── App/                       # Application entry point
│   │   └── ClockedOutApp.swift
│   ├── Models/                    # Data models
│   │   ├── TimeEntry.swift
│   │   ├── MonthlySummary.swift
│   │   ├── WeeklySummary.swift
│   │   └── HourlyRates.swift
│   ├── Views/                     # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── ImportView.swift
│   │   ├── ReportView.swift
│   │   ├── SettingsView.swift
│   │   └── Components/            # Reusable UI components
│   ├── ViewModels/                # MVVM view models
│   │   ├── ImportViewModel.swift
│   │   ├── ReportViewModel.swift
│   │   └── SettingsViewModel.swift
│   ├── Services/                  # Business logic
│   │   ├── CSVParser.swift
│   │   ├── TimeCalculator.swift
│   │   ├── ReportGenerator.swift
│   │   └── ExportService.swift
│   ├── Database/                  # Database layer
│   │   ├── DatabaseManager.swift
│   │   ├── DatabaseError.swift
│   │   ├── MonthlySummaryRepository.swift
│   │   ├── WeeklySummaryRepository.swift
│   │   └── Migrations/            # Database migrations
│   ├── Utilities/                 # Helper utilities
│   │   ├── Extensions/
│   │   ├── Formatters/
│   │   ├── Validation/
│   │   ├── Logging/
│   │   └── Preferences/
│   └── Errors/                    # Error types
├── Package.swift                  # Swift Package Manager config
├── project.yml                    # XcodeGen configuration
├── setup_xcode_project.sh         # Setup script
├── BUILD_INSTRUCTIONS.md          # Detailed build instructions
└── QUICK_START.md                 # Quick start guide
```

## 🔧 Building from Source

### Prerequisites

1. Install **Xcode** from the App Store
2. Install **Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```
3. (Optional) Install **Homebrew** for easier dependency management:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Build Steps

1. **Clone or download** the repository
2. **Generate Xcode project**:
   ```bash
   brew install xcodegen
   xcodegen generate
   ```
3. **Open in Xcode**:
   ```bash
   open ClockedOut.xcodeproj
   ```
4. **Build**:
   - Select the "ClockedOut" scheme
   - Press `Cmd+B` to build
   - Press `Cmd+R` to build and run

### Creating a Distributable App

1. **Archive** the app:
   - Product > Archive in Xcode
   - Wait for the archive to complete

2. **Export**:
   - In Organizer, select your archive
   - Click "Distribute App"
   - Choose "Copy App" to create a standalone `.app` file

3. **Install**:
   - Move the `.app` file to `/Applications`
   - Double-click to launch

## 📝 CSV Format

The app expects CSV files with the following columns:

- **Start Text** - Date/time string (supports IST timezone conversion)
- **Time Tracked** - Time tracked in milliseconds

Example CSV format:
```csv
Start Text,Time Tracked
2024-01-15 09:00:00 IST,28800000
2024-01-16 09:30:00 IST,25200000
```

## 🗄️ Database

ClockedOut uses SQLite for data persistence. The database is stored at:

```
~/Library/Application Support/ClockedOut/clockedout.db
```

The database includes:
- **Time Entries** - Imported time tracking data
- **Monthly Summaries** - Aggregated monthly data with salary calculations
- **Weekly Summaries** - Weekly breakdowns for reporting

Database migrations are handled automatically on app launch.

## 🐛 Troubleshooting

### Common Issues

**Import errors**
- Ensure your CSV file has the required columns: "Start Text" and "Time Tracked"
- Check that dates are in a recognizable format
- Verify time values are in milliseconds

**Database errors**
- Check Console.app for detailed error messages
- Ensure you have write permissions in `~/Library/Application Support/`
- Try deleting the database file to reset (⚠️ this will delete all data)

**Build errors**
- Ensure GRDB package dependency is properly added
- Check that all source files are added to the ClockedOut target
- Verify minimum deployment target is macOS 13.0

**App crashes**
- Check Console.app for crash logs
- Verify database permissions
- Try resetting the database (see above)

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Step-by-step setup guide
- **[BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)** - Detailed build instructions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is available for use as specified in the license file (if present).

## 🙏 Acknowledgments

- **GRDB** - SQLite toolkit for Swift
- **SwiftUI** - Apple's modern UI framework

---

**Made with ❤️ for macOS**
