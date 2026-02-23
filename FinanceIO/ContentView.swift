//
//  ContentView.swift
//  FinanceIO
//
//  Created by Utsab's Mac on 2/23/26.
//

import SwiftUI
import SwiftData

/// Root view of the app. Will be expanded in later phases
/// to host tabs for Expenses, Lending, Dashboard, and Settings.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Text("FinanceIO")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [ExpenseTransaction.self, Person.self, LendingTransaction.self],
            inMemory: true
        )
}
