//
//  ExpenseDetailView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// Displays full details of an expense transaction with edit and delete actions.
struct ExpenseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ExpenseCategory.sortOrder)
    private var categories: [ExpenseCategory]

    let expense: ExpenseTransaction

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirm = false

    // MARK: - Helpers

    private var categoryInfo: (icon: String, color: Color) {
        if let cat = categories.first(where: { $0.name == expense.category }) {
            return (cat.icon, cat.color)
        }
        return (iconFallback(for: expense.category), .gray)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- Header Card ---
                headerCard

                // --- Details ---
                detailsCard

                // --- Actions ---
                actionsSection
            }
            .padding()
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #endif
        .navigationTitle("Expense Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddExpenseView(editingExpense: expense)
        }
        .confirmationDialog(
            "Delete Expense?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(expense)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 14) {
            Image(systemName: categoryInfo.icon)
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(categoryInfo.color, in: Circle())

            Text(expense.amount, format: .currency(code: "NPR"))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(expense.category)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(categoryInfo.color)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(categoryInfo.color.opacity(0.12), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(
                icon: "calendar",
                title: "Date",
                value: expense.date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
            )

            Divider().padding(.leading, 44)

            if let method = expense.paymentMethod, !method.isEmpty {
                detailRow(
                    icon: "creditcard",
                    title: "Payment Method",
                    value: method
                )
                Divider().padding(.leading, 44)
            }

            if let note = expense.note, !note.isEmpty {
                detailRow(
                    icon: "text.alignleft",
                    title: "Note",
                    value: note
                )
            }
        }
        .padding(.vertical, 4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showingEditSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill")
                    Text("Edit Expense")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .controlSize(.large)

            Button(role: .destructive) {
                showingDeleteConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash.circle.fill")
                    Text("Delete Expense")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .controlSize(.large)
        }
        .padding(.top, 4)
    }

    // MARK: - Icon Fallback

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
    NavigationStack {
        ExpenseDetailView(
            expense: ExpenseTransaction(
                amount: 1250,
                date: .now,
                category: "Food",
                note: "Lunch at cafe",
                paymentMethod: "eSewa"
            )
        )
    }
    .modelContainer(
        for: [ExpenseTransaction.self, ExpenseCategory.self],
        inMemory: true
    )
}
