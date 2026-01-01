# ClockedOut ⏰

A native macOS application for tracking and analyzing time entries from CSV reports. ClockedOut helps you import time tracking data, calculate weekday and weekend hours based on the **Israeli work week** (Sunday–Thursday = weekday, Friday–Saturday = weekend), and generate comprehensive reports with salary calculations.

## ✨ Features

### Import & Parsing
- **📥 Drag & Drop Import** — Seamlessly import CSV files via drag-and-drop or file browser
- **🔄 Flexible Date Parsing** — Supports both Unix timestamps (milliseconds) and text-based date formats
- **👀 Import Preview** — Review entries, hours breakdown, and calculated salary before saving
- **✅ Rate Validation** — Real-time validation of hourly rates before import confirmation
- **🔁 Replace or Accumulate** — Choose to replace existing month data or accumulate hours

### Time Analysis
- **📊 Automatic Classification** — Weekday (Sun–Thu) and weekend (Fri–Sat) hours calculated automatically
- **📅 Weekly Breakdown** — Detailed weekly reports within each month
- **💰 Salary Calculations** — Automatic salary computation based on customizable hourly rates
- **🧮 Precise Rounding** — All hour and salary values rounded to 2 decimal places

### Reporting & Export
- **📈 Monthly Summaries** — Aggregate view with total hours and salary per month
- **📋 Weekly Reports** — Visual cards showing weekday/weekend hour breakdown per week
- **📤 PDF Export** — Generate beautifully formatted PDF reports
- **📄 CSV Export** — Export data in CSV format for spreadsheet analysis
- **📆 Month Selector** — Easy navigation between stored monthly reports

### User Experience
- **🎨 Modern SwiftUI Interface** — Clean, native macOS design with NavigationSplitView
- **✨ Smooth Animations** — Spring animations and transitions throughout the UI
- **🔔 Notification Banners** — Visual feedback for import success/errors
- **♿ Full Accessibility** — VoiceOver labels and accessibility traits on all interactive elements
- **⌨️ Keyboard Shortcuts** — Cmd+O for import, Cmd+S for save

### Data Storage
- **💾 SQLite Database** — Reliable persistent storage via GRDB
- **🔄 Automatic Migrations** — Database schema updates handled transparently
- **📁 App Support Directory** — Data stored in `~/Library/Application Support/ClockedOut/`

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

1. **Launch the app** — Build and run in Xcode, or open the `.app` file
2. **Configure rates** — Go to the **Settings** tab and set your:
   - Weekday Rate (Sunday–Thursday)
   - Weekend Rate (Friday–Saturday)
3. **Import data** — Navigate to the **Import** tab and:
   - Drag and drop your CSV file, or
   - Click "Browse Files" to select a file

### Import Flow

1. **Select a CSV file** — Drag and drop or use the file browser
2. **Review the preview** — See month, entry count, weekday/weekend hours
3. **Enter hourly rates** — Input your weekday and weekend rates
4. **Calculate salary** — Click "Calculate Salary" to validate and compute
5. **Save or Replace** — Confirm import (replace existing data or save new)

### Reports Tab

- **Month Selector** — Choose a month from the dropdown to view its report
- **Summary Cards** — View weekday hours, weekend hours, total hours, and salary
- **Weekly Breakdown** — Scroll through visual cards for each week
- **Export Options** — Use the Export menu to save as PDF or CSV

### Settings Tab

- Configure hourly rates for weekdays and weekends
- Rates are persisted and applied to future imports
- Validation ensures rates are positive numbers

## 🏗️ Architecture

ClockedOut follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **SwiftUI** — Modern declarative UI framework with NavigationSplitView
- **GRDB** — Type-safe SQLite wrapper for database operations
- **Modern Swift Concurrency** — async/await for all asynchronous operations
- **@MainActor** — Thread-safe UI updates

### Key Components

| Layer | Components | Purpose |
|-------|------------|---------|
| **Models** | `TimeEntry`, `MonthlySummary`, `WeeklySummary`, `WeeklyReport`, `HourlyRates` | Data structures and business logic |
| **Views** | `ContentView`, `ImportView`, `ReportView`, `SettingsView` | SwiftUI user interface |
| **ViewModels** | `ImportViewModel`, `ReportViewModel`, `SettingsViewModel` | State management and business logic |
| **Services** | `CSVParser`, `TimeCalculator`, `ReportGenerator`, `ExportService` | Core functionality |
| **Database** | `DatabaseManager`, Repositories, Migrations | SQLite persistence layer |
| **Utilities** | Formatters, Validators, Extensions, Logger | Helper functions |

### Design Patterns

- **Repository Pattern** — `MonthlySummaryRepository`, `WeeklySummaryRepository` for data access
- **Singleton Services** — Shared instances for `CSVParser`, `TimeCalculator`, `ExportService`
- **Dependency Injection** — ViewModels receive repositories via initializer
- **Protocol-Oriented** — GRDB conformance via `TableRecord`, `FetchableRecord`, `PersistableRecord`

## 📁 Project Structure

```
ClockedOut/
├── ClockedOut/                    # Main source code
│   ├── App/                       # Application entry point
│   │   └── ClockedOutApp.swift    # @main entry, window configuration
│   ├── Models/                    # Data models
│   │   ├── TimeEntry.swift        # Individual time entries with CSV parsing
│   │   ├── MonthlySummary.swift   # Monthly aggregate with GRDB conformance
│   │   ├── WeeklySummary.swift    # Weekly database record
│   │   ├── WeeklyReport.swift     # Weekly report display model
│   │   └── HourlyRates.swift      # Rate configuration struct
│   ├── Views/                     # SwiftUI views
│   │   ├── ContentView.swift      # Main navigation with tab selection
│   │   ├── ImportView.swift       # Import flow with drag-drop zone
│   │   ├── ReportView.swift       # Monthly/weekly report display
│   │   ├── SettingsView.swift     # Rate configuration form
│   │   ├── WeeklyReportCard.swift # Individual week card component
│   │   └── Components/            # Reusable UI components
│   │       ├── EmptyStateView.swift
│   │       ├── ErrorView.swift
│   │       ├── LoadingView.swift
│   │       ├── MonthSelector.swift
│   │       ├── StatCard.swift
│   │       └── TimeDisplay.swift
│   ├── ViewModels/                # MVVM view models
│   │   ├── ImportViewModel.swift  # Import state, validation, preview
│   │   ├── ReportViewModel.swift  # Report loading and generation
│   │   └── SettingsViewModel.swift # Rate settings with validation
│   ├── Services/                  # Business logic
│   │   ├── CSVParser.swift        # CSV parsing with flexible date support
│   │   ├── TimeCalculator.swift   # Hour classification and aggregation
│   │   ├── ReportGenerator.swift  # Report data assembly
│   │   └── ExportService.swift    # PDF and CSV export
│   ├── Database/                  # Database layer
│   │   ├── DatabaseManager.swift  # Initialization and migrations
│   │   ├── DatabaseError.swift    # Database-specific errors
│   │   ├── MonthlySummaryRepository.swift
│   │   ├── WeeklySummaryRepository.swift
│   │   └── Migrations/            # Database schema migrations
│   │       ├── Migration001_InitialSchema.swift
│   │       └── Migration002_AddIndexes.swift
│   ├── Utilities/                 # Helper utilities
│   │   ├── Extensions/            # Date, Double extensions
│   │   ├── Formatters/            # Currency, Date, Time formatters
│   │   ├── Validation/            # Input validation
│   │   ├── Logging/               # OSLog-based logging
│   │   └── Preferences/           # UserDefaults management
│   └── Errors/                    # Custom error types
│       ├── AppError.swift
│       ├── ParserError.swift
│       └── ValidationError.swift
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

| Column | Required | Description |
|--------|----------|-------------|
| `Start` | One of these | Unix timestamp in milliseconds |
| `Start Text` | One of these | Date/time string (multiple formats supported) |
| `Time Tracked` | Yes | Duration in milliseconds |

### Example CSV (with Unix timestamp):
```csv
Start,Time Tracked
1705312800000,28800000
1705399200000,25200000
```

### Example CSV (with text date):
```csv
Start Text,Time Tracked
2024-01-15 09:00:00 IST,28800000
2024-01-16 09:30:00 IST,25200000
```

### Supported Date Formats

- ISO 8601: `2024-01-15T09:00:00Z`
- With timezone: `2024-01-15 09:00:00 IST`
- Standard: `2024-01-15 09:00:00`
- Unix timestamp (milliseconds): `1705312800000`

## 🗄️ Database

ClockedOut uses SQLite for data persistence via the GRDB library. The database is stored at:

```
~/Library/Application Support/ClockedOut/clockedout.db
```

### Schema

**monthly_summaries**
- `id` — Primary key
- `month` — Format: "MM/YYYY"
- `weekday_hours`, `weekend_hours` — Decimal hours
- `weekday_rate`, `weekend_rate` — Hourly rates
- `salary` — Calculated salary
- `created_at`, `updated_at` — ISO8601 timestamps

**weekly_summaries**
- `id` — Primary key
- `month_id` — Foreign key to monthly_summaries
- `week_start_date`, `week_end_date` — ISO8601 dates
- `weekday_hours`, `weekend_hours` — Decimal hours

### Migrations

Database migrations are handled automatically on app launch:
- `001_InitialSchema` — Creates base tables
- `002_AddIndexes` — Adds performance indexes

## 🐛 Troubleshooting

### Common Issues

**Import errors**
- Ensure your CSV file has `Time Tracked` column (required)
- Must have either `Start` (Unix timestamp) or `Start Text` (date string) column
- Verify time values are in milliseconds
- Check Console.app for detailed parsing errors

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

**Rate validation fails**
- Ensure rates are positive numbers
- Remove any currency symbols or commas
- Click "Calculate Salary" before saving

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** — Step-by-step setup guide
- **[BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)** — Detailed build instructions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is available for use as specified in the license file (if present).

## 🙏 Acknowledgments

- **[GRDB](https://github.com/groue/GRDB.swift)** — SQLite toolkit for Swift
- **SwiftUI** — Apple's modern UI framework

---

**Made with ❤️ for macOS**
