//
//  DashboardView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData
import Charts

/// Summary dashboard showing monthly spend, lending overview,
/// a category breakdown chart, and a combined recent activity feed.
struct DashboardView: View {

    // MARK: - Queries (auto-refresh on data changes)

    @Query(sort: \ExpenseTransaction.date, order: .reverse)
    private var expenses: [ExpenseTransaction]

    @Query(sort: \Person.name)
    private var people: [Person]

    @Query(sort: \LendingTransaction.date, order: .reverse)
    private var lendingTransactions: [LendingTransaction]

    @Query(sort: \ExpenseCategory.sortOrder)
    private var expenseCategories: [ExpenseCategory]

    // MARK: - Computed Properties

    /// Start of the current calendar month.
    private var startOfMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: .now)
        )!
    }

    /// Total expenses for the current month.
    private var monthlyTotal: Double {
        expenses
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    /// Net lending balance across all people.
    private var lendingNet: Double {
        people.reduce(0) { $0 + $1.netBalance }
    }

    /// Per-category spending totals for all time (used in the chart).
    private var categoryTotals: [(category: String, total: Double)] {
        Dictionary(grouping: expenses, by: \.category)
            .map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    /// Combined recent activity: latest 5 items from expenses + lending, sorted by date.
    private var recentActivity: [ActivityItem] {
        let expenseItems: [ActivityItem] = expenses.prefix(5).map { exp in
            let catIcon = expenseCategories.first(where: { $0.name == exp.category })?.icon ?? "cart"
            return ActivityItem(
                title: exp.category,
                subtitle: exp.paymentMethod,
                amount: -exp.amount,          // expenses are outgoing
                date: exp.date,
                icon: catIcon,
                kind: .expense
            )
        }
        let lendingItems: [ActivityItem] = lendingTransactions.prefix(5).map {
            ActivityItem(
                title: $0.person?.name ?? "Unknown",
                subtitle: $0.note,
                amount: $0.amount,
                date: $0.date,
                icon: "person.2",
                kind: .lending
            )
        }
        return (expenseItems + lendingItems)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }               // convert ArraySlice → Array
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // --- Summary Cards ---
                    summaryCards

                    // --- Category Pie Chart ---
                    categoryChart

                    // --- Recent Activity ---
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Summary")
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            #endif
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Monthly Spend",
                value: monthlyTotal,
                icon: "banknote",
                color: .red
            )
            SummaryCard(
                title: lendingNet >= 0 ? "People Owe Me" : "I Owe People",
                value: abs(lendingNet),
                icon: "person.2.circle",
                color: lendingNet >= 0 ? .green : .orange
            )
        }
    }

    // MARK: - Category Chart

    @ViewBuilder
    private var categoryChart: some View {
        if categoryTotals.isEmpty {
            // Nothing to chart yet
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Spending by Category")
                    .font(.headline)

                Chart(categoryTotals, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.total),
                        innerRadius: .ratio(0.5),
                        angularInset: 1
                    )
                    .foregroundStyle(by: .value("Category", item.category))
                    .cornerRadius(4)
                }
                .chartLegend(position: .bottom, spacing: 10)
                .frame(height: 220)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.headline)

            if recentActivity.isEmpty {
                Text("No activity yet.")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(recentActivity) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundStyle(item.kind == .expense ? .red : .blue)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.amount, format: .currency(code: "NPR"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(item.amount >= 0 ? .green : .red)
                            Text(item.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    if item.id != recentActivity.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Summary Card

/// A compact card displaying a title, formatted currency value, and icon.
private struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value, format: .currency(code: "NPR"))
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Activity Item

/// Unified model for combining expense and lending items in the activity feed.
private struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let amount: Double
    let date: Date
    let icon: String
    let kind: Kind

    enum Kind {
        case expense, lending
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .modelContainer(
            for: [ExpenseTransaction.self, Person.self, LendingTransaction.self, ExpenseCategory.self],
            inMemory: true
        )
}
