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
    @State private var showDatePicker: Bool = false

    // MARK: - Options

    /// Category definitions with SF Symbol icons and colors.
    static let categories: [(name: String, icon: String, color: Color)] = [
        ("Food",          "fork.knife",           .orange),
        ("Transport",     "car.fill",             .blue),
        ("Rent",          "house.fill",           .purple),
        ("Shopping",      "bag.fill",             .pink),
        ("Utilities",     "bolt.fill",            .yellow),
        ("Entertainment", "tv.fill",              .indigo),
        ("Health",        "heart.fill",           .red),
        ("Education",     "book.fill",            .teal),
        ("Other",         "ellipsis.circle.fill", .gray),
    ]

    /// Available payment methods with icons.
    static let paymentMethods: [(name: String, icon: String)] = [
        ("Cash",     "banknote"),
        ("eSewa",    "iphone"),
        ("Khalti",   "creditcard"),
        ("Nabil",    "building.columns"),
        ("NIC Asia", "building.columns.fill"),
    ]

    // MARK: - Computed

    private var selectedCategoryInfo: (name: String, icon: String, color: Color) {
        Self.categories.first { $0.name == category }
            ?? ("Other", "ellipsis.circle.fill", .gray)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    amountCard
                    categorySection
                    dateSection
                    noteSection
                    paymentMethodSection
                    saveButton
                }
                .padding()
            }
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            #endif
            .navigationTitle("Add Expense")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }

    // MARK: - Amount Card

    private var amountCard: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedCategoryInfo.icon)
                .font(.system(size: 32))
                .foregroundStyle(selectedCategoryInfo.color)
                .frame(width: 56, height: 56)
                .background(selectedCategoryInfo.color.opacity(0.15))
                .clipShape(Circle())

            Text("NPR")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            TextField("0.00", text: $amount)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
        }
        .padding(.vertical, 24)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Category", systemImage: "square.grid.2x2")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                spacing: 10
            ) {
                ForEach(Self.categories, id: \.name) { cat in
                    let isSelected = category == cat.name
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            category = cat.name
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.title3)
                                .foregroundStyle(isSelected ? .white : cat.color)
                                .frame(width: 36, height: 36)
                                .background(
                                    isSelected
                                        ? AnyShapeStyle(cat.color)
                                        : AnyShapeStyle(cat.color.opacity(0.12))
                                )
                                .clipShape(Circle())

                            Text(cat.name)
                                .font(.caption2)
                                .fontWeight(isSelected ? .bold : .medium)
                                .foregroundStyle(isSelected ? cat.color : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isSelected
                                ? cat.color.opacity(0.08)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isSelected ? cat.color.opacity(0.3) : .clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack {
                    Label("Date", systemImage: "calendar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(date, format: .dateTime.day().month(.abbreviated).year())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if showDatePicker {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Note Section

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Note", systemImage: "text.alignleft")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextField("What was this expense for?", text: $note, axis: .vertical)
                .lineLimit(2...4)
                .font(.body)
                .padding(12)
                .background(
                    Color.primary.opacity(0.04),
                    in: RoundedRectangle(cornerRadius: 10)
                )
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Payment Method Section

    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Payment Method", systemImage: "creditcard")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Self.paymentMethods, id: \.name) { method in
                        let isSelected = paymentMethod == method.name
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                paymentMethod = method.name
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: method.icon)
                                    .font(.caption)
                                Text(method.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(Color.accentColor)
                                    : AnyShapeStyle(Color.primary.opacity(0.06)),
                                in: Capsule()
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveExpense()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Expense")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .controlSize(.large)
        .disabled(!isValid)
        .padding(.top, 4)
    }

    // MARK: - Validation

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
