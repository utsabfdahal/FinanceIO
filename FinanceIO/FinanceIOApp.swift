//
//  FinanceIOApp.swift
//  FinanceIO
//
//  Created by Utsab's Mac on 2/23/26.
//

import SwiftUI
import SwiftData

@main
struct FinanceIOApp: App {

    /// Shared ModelContainer that registers all SwiftData models.
    /// The container is persisted on disk (isStoredInMemoryOnly: false).
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExpenseTransaction.self,
            Person.self,
            LendingTransaction.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
