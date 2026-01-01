import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .`import`
    @State private var monthlyRepo: MonthlySummaryRepository?
    @State private var weeklyRepo: WeeklySummaryRepository?
    @State private var importViewModel: ImportViewModel?
    @State private var reportViewModel: ReportViewModel?
    @State private var settingsViewModel: SettingsViewModel?
    @State private var databaseInitialized = false
    
    enum Tab: String, CaseIterable {
        case `import` = "Import"
        case reports = "Reports"
        case settings = "Settings"
    }
    
    var body: some View {
        Group {
            if !databaseInitialized {
                LoadingView(message: "Initializing database...")
                    .task {
                        await initializeDatabase()
                    }
            } else if let importVM = importViewModel,
                      let reportVM = reportViewModel,
                      let settingsVM = settingsViewModel {
                NavigationSplitView {
                    List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                        Label(tab.rawValue, systemImage: icon(for: tab))
                            .tag(tab)
                    }
                    .navigationTitle("ClockedOut")
                } detail: {
                    Group {
                        switch selectedTab {
                        case .`import`:
                            ImportView(viewModel: importVM)
                        case .reports:
                            ReportView(viewModel: reportVM)
                        case .settings:
                            SettingsView(viewModel: settingsVM)
                        }
                    }
                }
            } else {
                ErrorView(
                    error: DatabaseError.connectionFailed(NSError(domain: "ContentView", code: -1)),
                    retryAction: {
                        Task {
                            await initializeDatabase()
                        }
                    }
                )
            }
        }
    }
    
    private func icon(for tab: Tab) -> String {
        switch tab {
        case .`import`:
            return "square.and.arrow.down"
        case .reports:
            return "chart.bar"
        case .settings:
            return "gearshape"
        }
    }
    
    private func initializeDatabase() async {
        do {
            try DatabaseManager.shared.initialize()
            let dbQueue = try DatabaseManager.shared.getDatabaseQueue()
            
            let monthly = MonthlySummaryRepository(dbQueue: dbQueue)
            let weekly = WeeklySummaryRepository(dbQueue: dbQueue)
            
            await MainActor.run {
                monthlyRepo = monthly
                weeklyRepo = weekly
                importViewModel = ImportViewModel(monthlyRepo: monthly, weeklyRepo: weekly)
                reportViewModel = ReportViewModel(monthlyRepo: monthly, weeklyRepo: weekly)
                settingsViewModel = SettingsViewModel(monthlyRepo: monthly)
                databaseInitialized = true
            }
        } catch {
            Logger.error("Failed to initialize database", error: error, log: Logger.database)
            await MainActor.run {
                databaseInitialized = true // Show error state
            }
        }
    }
}

#Preview {
    ContentView()
}

