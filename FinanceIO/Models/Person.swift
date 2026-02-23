//
//  Person.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation
import SwiftData

/// Represents a person in the lending/borrowing panel.
/// Each person has a running net balance and a list of associated lending transactions.
@Model
final class Person {

    // MARK: - Properties

    /// Unique identifier for the person.
    var id: UUID

    /// The person's display name.
    var name: String

    /// Net balance with this person.
    /// Positive = they owe you, Negative = you owe them.
    var netBalance: Double

    /// All lending/borrowing transactions associated with this person.
    /// Uses SwiftData's `@Relationship` with a cascade delete rule so that
    /// deleting a Person also removes their related transactions.
    @Relationship(deleteRule: .cascade, inverse: \LendingTransaction.person)
    var transactions: [LendingTransaction]

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        netBalance: Double = 0,
        transactions: [LendingTransaction] = []
    ) {
        self.id = id
        self.name = name
        self.netBalance = netBalance
        self.transactions = transactions
    }
}
