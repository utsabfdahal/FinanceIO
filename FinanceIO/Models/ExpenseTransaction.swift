//
//  ExpenseTransaction.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation
import SwiftData

/// Represents a single expense transaction (e.g., food, transport, utilities).
/// Stored locally using SwiftData.
@Model
final class ExpenseTransaction {

    // MARK: - Properties

    /// Unique identifier for the transaction.
    var id: UUID

    /// The monetary amount of the expense.
    var amount: Double

    /// The date the expense occurred.
    var date: Date

    /// Category of the expense (e.g., "Food", "Transport", "Utilities").
    var category: String

    /// An optional note or description for additional context.
    var note: String?

    /// The payment method used (e.g., "eSewa", "Nabil", "NIC", "Khalti", "Cash").
    var paymentMethod: String?

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = .now,
        category: String,
        note: String? = nil,
        paymentMethod: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.category = category
        self.note = note
        self.paymentMethod = paymentMethod
    }
}
