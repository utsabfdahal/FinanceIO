//
//  CSVExporter.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import Foundation

/// Generates a combined CSV file from expense and lending transaction data.
/// The CSV follows the structure:
///   Date, Type, Description, Amount, Note, Method
struct CSVExporter {

    /// ISO date formatter used for the Date column (yyyy-MM-dd).
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Builds a CSV string and writes it to a temporary `.csv` file.
    /// - Parameters:
    ///   - expenses: All expense transactions to include.
    ///   - people: All people (used to iterate their lending transactions).
    /// - Returns: A file `URL` pointing to the generated CSV, or `nil` on failure.
    static func export(
        expenses: [ExpenseTransaction],
        people: [Person]
    ) -> URL? {
        var csv = "Date,Type,Description,Amount,Note,Method\n"

        // --- Expense rows ---
        for e in expenses {
            let date = dateFormatter.string(from: e.date)
            let note = sanitize(e.note ?? "")
            let method = sanitize(e.paymentMethod ?? "")
            csv += "\(date),Expense,\(sanitize(e.category)),\(e.amount),\(note),\(method)\n"
        }

        // --- Lending rows ---
        for person in people {
            for tx in person.transactions {
                let date = dateFormatter.string(from: tx.date)
                let note = sanitize(tx.note ?? "")
                let direction = tx.amount >= 0 ? "Lent" : "Received"
                csv += "\(date),\(direction),\(sanitize(person.name)),\(tx.amount),\(note),\n"
            }
        }

        // Write to a temporary file
        let fileName = "FinanceIO_Export_\(dateFormatter.string(from: .now)).csv"
        let url = URL.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("CSVExporter: Failed to write file – \(error.localizedDescription)")
            return nil
        }
    }

    /// Wraps a value in double-quotes and escapes internal quotes for CSV safety.
    private static func sanitize(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
