//
//  PeopleListView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// Displays all people in the lending/borrowing panel.
/// Each row shows the person's name and color-coded net balance.
struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext

    /// All people, sorted alphabetically by name.
    @Query(sort: \Person.name) private var people: [Person]

    /// Controls the Add Person alert.
    @State private var showingAddPerson = false

    /// Name entered in the Add Person alert.
    @State private var newPersonName = ""

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView(
                        "No People",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap + to add someone you lend to or borrow from.")
                    )
                } else {
                    List {
                        ForEach(people) { person in
                            NavigationLink(destination: PersonDetailView(person: person)) {
                                PersonRow(person: person)
                            }
                        }
                        .onDelete(perform: deletePeople)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Lending")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        newPersonName = ""
                        showingAddPerson = true
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .alert("Add Person", isPresented: $showingAddPerson) {
                TextField("Name", text: $newPersonName)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addPerson()
                }
                .disabled(newPersonName.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Enter the person's name.")
            }
        }
    }

    // MARK: - Actions

    /// Inserts a new Person with zero balance.
    private func addPerson() {
        let trimmed = newPersonName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let person = Person(name: trimmed)
        modelContext.insert(person)
    }

    /// Deletes people (and their transactions via cascade) at the given offsets.
    private func deletePeople(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(people[index])
            }
        }
    }
}

// MARK: - Person Row

/// A single row showing a person's name and color-coded net balance.
private struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack {
            // Avatar + name
            Label(person.name, systemImage: "person.circle")
                .font(.headline)

            Spacer()

            // Color-coded balance
            Text(person.netBalance, format: .currency(code: "NPR"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(balanceColor)
        }
        .padding(.vertical, 4)
    }

    /// Green if they owe you, red if you owe them, secondary if zero.
    private var balanceColor: Color {
        if person.netBalance > 0 { return .green }
        if person.netBalance < 0 { return .red }
        return .secondary
    }
}

#Preview {
    PeopleListView()
        .modelContainer(
            for: [Person.self, LendingTransaction.self],
            inMemory: true
        )
}
