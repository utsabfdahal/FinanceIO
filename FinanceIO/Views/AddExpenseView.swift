//
//  AddExpenseView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// A sheet-presented form for adding a new expense transaction.
struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State

    @State private var amount: String = ""
    @State private var category: String = "Food"
    @State private var date: Date = .now
    @State private var note: String = ""
    @State private var paymentMethod: String = "Cash"

    // MARK: - Options

    /// Predefined expense categories.
    static let categories = [
        "Food", "Transport", "Rent", "Shopping",
        "Utilities", "Entertainment", "Health", "Education", "Other"
    ]

    /// Available payment methods.
    static let paymentMethods = [
        "Cash", "eSewa", "Khalti", "Nabil", "NIC Asia"
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // --- Amount ---
                Section("Amount") {
                    TextField("0.00", text: $amount)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }

                // --- Category ---
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(Self.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // --- Date ---
                Section("Date") {
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }

                // --- Note (optional) ---
                Section("Note") {
                    TextField("Optional note", text: $note)
                }

                // --- Payment Method (optional) ---
                Section("Payment Method") {
                    Picker("Method", selection: $paymentMethod) {
                        ForEach(Self.paymentMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add Expense")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Validation

    /// The amount field must contain a valid positive number.
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else { return false }
        return true
    }

    // MARK: - Save

    private func saveExpense() {
        guard let value = Double(amount) else { return }

        let expense = ExpenseTransaction(
            amount: value,
            date: date,
            category: category,
            note: note.isEmpty ? nil : note,
            paymentMethod: paymentMethod
        )
        modelContext.insert(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: ExpenseTransaction.self, inMemory: true)
}
