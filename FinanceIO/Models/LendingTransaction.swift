//
//  LendingTransaction.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation
import SwiftData

/// Represents a single lending or borrowing transaction tied to a specific Person.
/// Positive amounts indicate money lent; negative amounts indicate money repaid or borrowed.
@Model
final class LendingTransaction {

    // MARK: - Properties

    /// Unique identifier for the transaction.
    var id: UUID

    /// The monetary amount.
    /// Positive = you lent money, Negative = repaid or borrowed.
    var amount: Double

    /// The date the transaction occurred.
    var date: Date

    /// An optional note or description for additional context.
    var note: String?

    /// The person this transaction belongs to (inverse of `Person.transactions`).
    var person: Person?

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = .now,
        note: String? = nil,
        person: Person? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
        self.person = person
    }
}
