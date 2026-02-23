# FinanceIO

A personal finance tracker for iOS built with SwiftUI and SwiftData. It tracks daily expenses, manages lending and borrowing with people, and provides a visual summary of your spending. All data is stored locally on your device.

## Features

### Expense Tracking
- Add expenses with amount, category, date, optional note, and payment method.
- View all expenses in a list sorted by date (newest first).
- Tap any expense to see full details including category, amount, date, payment method, and note.
- Edit or delete expenses from the detail screen.
- Swipe to delete from the list.

### Custom Categories
- Nine built-in expense categories are provided by default: Food, Transport, Rent, Shopping, Utilities, Entertainment, Health, Education, and Other.
- Add your own custom categories from Settings with a name, icon (chosen from a grid of SF Symbols), and color.
- Edit existing categories at any time.
- Delete custom categories (built-in defaults are protected).

### Lending and Borrowing
- Add people you lend money to or borrow from.
- Record transactions against each person (lent or received).
- View each person's full transaction history and net balance.
- Net balance is color-coded: green if they owe you, red if you owe them.
- Swipe to delete individual transactions or people (cascade-deletes their transactions).

### Dashboard
- Monthly spending total.
- Net lending balance across all people.
- Pie chart showing spending by category (powered by Swift Charts).
- Recent activity feed combining the latest expenses and lending transactions.

### Data Export
- Export all expenses and lending transactions to a CSV file from Settings.
- The CSV includes date, type, description, amount, note, and payment method.
- Opens the system share sheet so you can save, AirDrop, or send the file.

### Settings
- Manage expense categories (add, edit, delete).
- Export data to CSV.
- View statistics (total expenses, people, lending transactions).
- Clear all data with a confirmation prompt.

## Payment Methods

The following payment methods are available when adding an expense:

- Cash
- eSewa
- Khalti
- Nabil
- NIC Asia

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- macOS Ventura or later (for building)

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/your-username/FinanceIO.git
   ```

2. Open the project in Xcode:
   ```
   cd FinanceIO
   open FinanceIO.xcodeproj
   ```

3. Select a simulator or connect a physical device running iOS 17.0 or later.

4. Press Cmd+R to build and run.

No external dependencies or packages are required. The project uses only Apple frameworks: SwiftUI, SwiftData, and Swift Charts.

## Data Storage

All data is stored locally on the device using SwiftData. There is no server, no account, and no internet connection required. Deleting the app will delete all stored data.

## Project Structure

```
FinanceIO/
  FinanceIOApp.swift          -- App entry point and model container setup
  ContentView.swift           -- Tab bar, expense list, and expense row
  Models/
    ExpenseTransaction.swift  -- Expense data model
    Person.swift              -- Person data model (lending panel)
    LendingTransaction.swift  -- Lending transaction data model
    ExpenseCategory.swift     -- User-defined expense category model
  Views/
    DashboardView.swift       -- Summary dashboard with charts
    AddExpenseView.swift      -- Add/edit expense form
    ExpenseDetailView.swift   -- Expense detail and actions
    PeopleListView.swift      -- Lending panel people list
    PersonDetailView.swift    -- Person detail and transaction history
    AddLendingTransactionView.swift -- Add lending transaction form
    SettingsView.swift        -- Settings, export, and data management
    CategoryManagerView.swift -- Category add/edit/delete UI
  Helpers/
    CSVExporter.swift         -- CSV file generation
```
