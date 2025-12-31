import SwiftUI

@main
struct ClockedOutApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("File") {
                Button("Import CSV...") {
                    // Will be handled by ImportView
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentSize)
    }
}

