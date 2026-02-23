//
//  AddLendingTransactionView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// A sheet form for recording a new lending or borrowing transaction
/// against a specific person.
///
/// - Positive amount → you lent them money (they owe you more).
/// - Negative amount → they paid back, or you borrowed from them.
struct AddLendingTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The person this transaction applies to.
    let person: Person

    // MARK: - Form State

    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var isLending: Bool = true  // true = lent, false = received/borrowed

    var body: some View {
        NavigationStack {
            Form {
                // --- Direction ---
                Section("Type") {
                    Picker("Direction", selection: $isLending) {
                        Text("I Lent").tag(true)
                        Text("I Received").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                // --- Amount ---
                Section("Amount") {
                    TextField("0.00", text: $amountText)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }

                // --- Date ---
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                // --- Note (optional) ---
                Section("Note") {
                    TextField("Optional note", text: $note)
                }
            }
            .navigationTitle("Add Transaction")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTransaction() }
                        .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Validation

    /// Amount must be a valid positive number.
    private var isValid: Bool {
        guard let value = Double(amountText), value > 0 else { return false }
        return true
    }

    // MARK: - Save

    private func saveTransaction() {
        guard let value = Double(amountText) else { return }

        // Apply sign based on direction
        let signedAmount = isLending ? value : -value

        // Create and link the transaction to the person
        let tx = LendingTransaction(
            amount: signedAmount,
            date: date,
            note: note.isEmpty ? nil : note,
            person: person
        )
        modelContext.insert(tx)

        // Update the person's running net balance
        person.netBalance += signedAmount

        dismiss()
    }
}

#Preview {
    AddLendingTransactionView(person: Person(name: "Preview User"))
        .modelContainer(
            for: [Person.self, LendingTransaction.self],
            inMemory: true
        )
}
