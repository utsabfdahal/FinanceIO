//
//  CategoryManagerView.swift
//  FinanceIO
//
//  Created on 2/23/26.
//

import SwiftUI
import SwiftData

/// Allows users to view, add, edit, and delete expense categories from Settings.
struct CategoryManagerView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.sortOrder)
    private var categories: [ExpenseCategory]

    @State private var showingAddSheet = false
    @State private var editingCategory: ExpenseCategory?

    var body: some View {
        List {
            if categories.isEmpty {
                ContentUnavailableView(
                    "No Categories",
                    systemImage: "tag.slash",
                    description: Text("Tap + to create a category.")
                )
            } else {
                ForEach(categories) { cat in
                    Button {
                        editingCategory = cat
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: cat.icon)
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(cat.color, in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                if cat.isDefault {
                                    Text("Built-in")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteCategories)
            }
        }
        .navigationTitle("Expense Categories")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Category", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CategoryFormView(mode: .add)
        }
        .sheet(item: $editingCategory) { cat in
            CategoryFormView(mode: .edit(cat))
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let cat = categories[index]
                if !cat.isDefault {
                    modelContext.delete(cat)
                }
            }
        }
    }
}

// MARK: - Category Form View (Add / Edit)

/// A sheet form for creating or editing an expense category.
struct CategoryFormView: View {
    enum Mode: Identifiable {
        case add
        case edit(ExpenseCategory)

        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let cat): return cat.id.uuidString
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColorHex: String = "#8E8E93"

    /// Common SF Symbol choices for categories.
    static let iconOptions: [String] = [
        "tag.fill", "fork.knife", "car.fill", "house.fill", "bag.fill",
        "bolt.fill", "tv.fill", "heart.fill", "book.fill", "airplane",
        "gift.fill", "cup.and.saucer.fill", "fuelpump.fill", "pawprint.fill",
        "dumbbell.fill", "gamecontroller.fill", "music.note", "cross.case.fill",
        "wrench.and.screwdriver.fill", "graduationcap.fill", "phone.fill",
        "wifi", "tshirt.fill", "figure.walk", "bicycle", "bus.fill",
        "cart.fill", "bed.double.fill", "leaf.fill", "drop.fill",
        "flame.fill", "scissors", "paintbrush.fill", "camera.fill",
        "ellipsis.circle.fill",
    ]

    /// Color palette for category colors.
    static let colorOptions: [(name: String, hex: String)] = [
        ("Red",    "#FF3B30"),
        ("Orange", "#FF9500"),
        ("Yellow", "#FFCC00"),
        ("Green",  "#34C759"),
        ("Teal",   "#5AC8FA"),
        ("Blue",   "#007AFF"),
        ("Indigo", "#5856D6"),
        ("Purple", "#AF52DE"),
        ("Pink",   "#FF2D55"),
        ("Brown",  "#A2845E"),
        ("Gray",   "#8E8E93"),
    ]

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var title: String {
        isEditing ? "Edit Category" : "New Category"
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // --- Preview ---
                    preview

                    // --- Name ---
                    nameField

                    // --- Icon picker ---
                    iconPicker

                    // --- Color picker ---
                    colorPicker
                }
                .padding()
            }
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            #endif
            .navigationTitle(title)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Add") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if case .edit(let cat) = mode {
                    name = cat.name
                    selectedIcon = cat.icon
                    selectedColorHex = cat.colorHex
                }
            }
        }
    }

    // MARK: - Preview

    private var preview: some View {
        VStack(spacing: 10) {
            Image(systemName: selectedIcon)
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: selectedColorHex), in: Circle())

            Text(name.isEmpty ? "Category Name" : name)
                .font(.headline)
                .foregroundStyle(name.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Name Field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Name", systemImage: "character.cursor.ibeam")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            TextField("e.g. Groceries, Gym, Pet Care", text: $name)
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

    // MARK: - Icon Picker

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Icon", systemImage: "star.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                spacing: 8
            ) {
                ForEach(Self.iconOptions, id: \.self) { icon in
                    let isSelected = selectedIcon == icon
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedIcon = icon
                        }
                    } label: {
                        Image(systemName: icon)
                            .font(.body)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .background(
                                isSelected
                                    ? AnyShapeStyle(Color(hex: selectedColorHex))
                                    : AnyShapeStyle(Color.primary.opacity(0.06)),
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Color Picker

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Color", systemImage: "paintpalette.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                spacing: 10
            ) {
                ForEach(Self.colorOptions, id: \.hex) { option in
                    let isSelected = selectedColorHex == option.hex
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedColorHex = option.hex
                        }
                    } label: {
                        Circle()
                            .fill(Color(hex: option.hex))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: isSelected ? 3 : 0)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        Color(hex: option.hex).opacity(0.5),
                                        lineWidth: isSelected ? 1 : 0
                                    )
                                    .padding(-2)
                            )
                            .scaleEffect(isSelected ? 1.15 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Save

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        switch mode {
        case .add:
            let category = ExpenseCategory(
                name: trimmed,
                icon: selectedIcon,
                colorHex: selectedColorHex
            )
            modelContext.insert(category)
        case .edit(let existing):
            existing.name = trimmed
            existing.icon = selectedIcon
            existing.colorHex = selectedColorHex
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryManagerView()
    }
    .modelContainer(for: ExpenseCategory.self, inMemory: true)
}
