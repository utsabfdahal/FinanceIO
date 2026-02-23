//
//  ContentView.swift
//  FinanceIO
//
//  Created by Utsab's Mac on 2/23/26.
//

import SwiftUI
import SwiftData

/// Root view of the app. Houses a TabView with Summary, Expenses, Lending, and Settings tabs.
struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Summary", systemImage: "chart.pie")
                }

            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "creditcard")
                }

            PeopleListView()
                .tabItem {
                    Label("Lending", systemImage: "person.2")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Expense List View

/// Displays all expenses sorted by date (newest first)
/// and provides a toolbar button to add new expenses via a sheet.
struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext

    /// All expenses, sorted newest-first.
    @Query(sort: \ExpenseTransaction.date, order: .reverse)
    private var expenses: [ExpenseTransaction]

    /// Dynamic categories for icons/colors.
    @Query(sort: \ExpenseCategory.sortOrder)
    private var categories: [ExpenseCategory]

    /// Controls presentation of the Add Expense sheet.
    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            Group {
                if expenses.isEmpty {
                    ContentUnavailableView(
                        "No Expenses",
                        systemImage: "tray",
                        description: Text("Tap + to add your first expense.")
                    )
                } else {
                    List {
                        ForEach(expenses) { expense in
                            NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                ExpenseRow(expense: expense, categories: categories)
                            }
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }

    // MARK: - Delete

    private func deleteExpenses(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(expenses[index])
            }
        }
    }
}

// MARK: - Expense Row

/// A single row showing category, date, amount, and payment method.
private struct ExpenseRow: View {
    let expense: ExpenseTransaction
    let categories: [ExpenseCategory]

    private var catInfo: (icon: String, color: Color) {
        if let cat = categories.first(where: { $0.name == expense.category }) {
            return (cat.icon, cat.color)
        }
        return (iconFallback(for: expense.category), .gray)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: catInfo.icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(catInfo.color, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.headline)
                Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amount, format: .currency(code: "NPR"))
                    .font(.headline)
                    .foregroundStyle(.red)
                if let method = expense.paymentMethod {
                    Text(method)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func iconFallback(for category: String) -> String {
        switch category {
        case "Food":          return "fork.knife"
        case "Transport":     return "car.fill"
        case "Rent":          return "house.fill"
        case "Shopping":      return "bag.fill"
        case "Utilities":     return "bolt.fill"
        case "Entertainment": return "tv.fill"
        case "Health":        return "heart.fill"
        case "Education":     return "book.fill"
        default:              return "ellipsis.circle"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [ExpenseTransaction.self, Person.self, LendingTransaction.self, ExpenseCategory.self],
            inMemory: true
        )
}
