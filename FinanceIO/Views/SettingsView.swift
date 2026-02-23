//
//  SettingsView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

/// App settings: data export and data management.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var expenses: [ExpenseTransaction]
    @Query private var people: [Person]
    @Query private var lendingTransactions: [LendingTransaction]

    /// Controls the destructive "Clear All Data" confirmation.
    @State private var showingClearConfirm = false

    /// Whether the daily 9 PM reminder is enabled.
    @State private var dailyReminderEnabled = false

    var body: some View {
        NavigationStack {
            List {
                // --- Notifications ---
                Section {
                    Toggle(isOn: $dailyReminderEnabled) {
                        Label("Daily Reminder", systemImage: "bell.badge")
                    }
                    .onChange(of: dailyReminderEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.enableDailyReminder()
                        } else {
                            NotificationManager.cancelDailyReminder()
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get a reminder every day at 9:00 PM to log your expenses.")
                }

                // --- Categories ---
                Section("Customization") {
                    NavigationLink(destination: CategoryManagerView()) {
                        Label("Expense Categories", systemImage: "square.grid.2x2")
                    }
                }

                // --- Data Management ---
                Section("Data Management") {
                    // Export
                    Button {
                        exportAndShare()
                    } label: {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(expenses.isEmpty && people.isEmpty)
                }

                // --- Info ---
                Section("Statistics") {
                    LabeledContent("Expenses", value: "\(expenses.count)")
                    LabeledContent("People", value: "\(people.count)")
                    LabeledContent("Lending Txns", value: "\(lendingTransactions.count)")
                }

                // --- Danger Zone ---
                Section {
                    Button(role: .destructive) {
                        showingClearConfirm = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete all expenses, people, and lending transactions.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $showingClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone. All expenses and lending records will be removed.")
            }
            .onAppear {
                NotificationManager.isReminderScheduled { scheduled in
                    dailyReminderEnabled = scheduled
                }
            }
        }
    }

    // MARK: - Actions

    /// Generates the CSV and presents the system share sheet directly.
    private func exportAndShare() {
        guard let url = CSVExporter.export(expenses: expenses, people: people) else { return }

        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        // Walk to the top-most presented controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        // iPad requires a popover source
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
        #endif
    }

    /// Deletes every record from all three model types.
    private func clearAllData() {
        withAnimation {
            for tx in lendingTransactions { modelContext.delete(tx) }
            for person in people { modelContext.delete(person) }
            for expense in expenses { modelContext.delete(expense) }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(
            for: [ExpenseTransaction.self, Person.self, LendingTransaction.self, ExpenseCategory.self],
            inMemory: true
        )
}
