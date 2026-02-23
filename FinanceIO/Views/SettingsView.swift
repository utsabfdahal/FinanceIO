//
//  SettingsView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// App settings: data export and data management.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var expenses: [ExpenseTransaction]
    @Query private var people: [Person]
    @Query private var lendingTransactions: [LendingTransaction]

    /// URL of the generated CSV file (set when the user taps Export).
    @State private var exportURL: URL?

    /// Controls the share sheet presentation.
    @State private var showingShareSheet = false

    /// Controls the destructive "Clear All Data" confirmation.
    @State private var showingClearConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // --- Data Management ---
                Section("Data Management") {
                    // Export
                    Button {
                        generateCSV()
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
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheetView(url: url)
                }
            }
        }
    }

    // MARK: - Actions

    /// Generates the CSV and presents the system share sheet.
    private func generateCSV() {
        if let url = CSVExporter.export(expenses: expenses, people: people) {
            exportURL = url
            showingShareSheet = true
        }
    }

    /// Deletes every record from all three model types.
    private func clearAllData() {
        withAnimation {
            // Delete lending transactions first (child), then people, then expenses
            for tx in lendingTransactions { modelContext.delete(tx) }
            for person in people { modelContext.delete(person) }
            for expense in expenses { modelContext.delete(expense) }
        }
    }
}

// MARK: - Share Sheet

#if os(iOS)
import UIKit

/// Wraps `UIActivityViewController` so we can share the CSV file URL.
private struct ShareSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
#else
import AppKit

/// macOS: wraps NSSharingServicePicker to share the CSV file URL.
private struct ShareSheetView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            let picker = NSSharingServicePicker(items: [url])
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}
#endif

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(
            for: [ExpenseTransaction.self, Person.self, LendingTransaction.self],
            inMemory: true
        )
}
