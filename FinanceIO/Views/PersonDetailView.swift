//
//  PersonDetailView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// Shows a person's current balance and full transaction history.
/// Allows adding new lending/borrowing transactions via a sheet.
struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext

    /// The person whose details are being viewed.
    let person: Person

    /// Controls presentation of the Add Transaction sheet.
    @State private var showingAddTransaction = false

    /// Transactions sorted newest-first (computed from the relationship).
    private var sortedTransactions: [LendingTransaction] {
        person.transactions.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            // --- Balance Summary ---
            Section {
                VStack(spacing: 8) {
                    Text("Net Balance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(person.netBalance, format: .currency(code: "NPR"))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(balanceColor)
                    Text(balanceLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            // --- Transaction History ---
            Section("Transactions") {
                if sortedTransactions.isEmpty {
                    Text("No transactions yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedTransactions) { tx in
                        TransactionRow(transaction: tx)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
        }
        .navigationTitle(person.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingAddTransaction = true
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddLendingTransactionView(person: person)
        }
    }

    // MARK: - Helpers

    private var balanceColor: Color {
        if person.netBalance > 0 { return .green }
        if person.netBalance < 0 { return .red }
        return .secondary
    }

    private var balanceLabel: String {
        if person.netBalance > 0 { return "They owe you" }
        if person.netBalance < 0 { return "You owe them" }
        return "Settled up"
    }

    /// Deletes transactions at the given offsets and updates the person's net balance.
    private func deleteTransactions(at offsets: IndexSet) {
        withAnimation {
            let sorted = sortedTransactions
            for index in offsets {
                let tx = sorted[index]
                // Reverse the effect on net balance
                person.netBalance -= tx.amount
                modelContext.delete(tx)
            }
        }
    }
}

// MARK: - Transaction Row

/// A single lending transaction row showing amount, date, and optional note.
private struct TransactionRow: View {
    let transaction: LendingTransaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Label based on direction
                Text(transaction.amount >= 0 ? "Lent" : "Received")
                    .font(.headline)
                Text(transaction.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "NPR"))
                .font(.headline)
                .foregroundStyle(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(person: Person(name: "Preview User", netBalance: 500))
    }
    .modelContainer(
        for: [Person.self, LendingTransaction.self],
        inMemory: true
    )
}
