# Money Manager

A comprehensive Flutter application for personal finance management with secure authentication, modern UI, and intuitive user experience.

## Features

### 🔐 Authentication System
- **Secure Login**: Email and password authentication with proper validation
- **User Registration**: Multi‑step signup with family details, dependencies and budget preferences
- **Session Management**: Persistent login state using secure storage
- **Local User Database**: Users are now persisted using SharedPreferences so accounts survive app restarts
- **Profile Editing**: Full profile update (name, email, phone, role, family members, dependencies, total income, budget preferences)
- **Demo Account**: Pre-configured demo account for testing

### 💰 Financial Dashboard
- **Balance Overview**: Real-time display of total balance, income, expenses, and savings
- **Budget Awareness**: Honors user budget preference (Daily / Monthly / Quarterly / Individual)
  - Daily = monthly budget ÷ 30
  - Quarterly = monthly budget × 3
  - Yearly = monthly budget × 12 (via Individual preference or future setting)
- **Quick Actions**: Easy access to add income, expenses, view reports, and settings
- **Recent Transactions**: List of recent financial activities with detailed information
- **Modern UI**: Beautiful gradient design with card-based layout

### 🛡️ Security Features
- **Secure Storage**: Sensitive data stored using Flutter Secure Storage
- **Form Validation**: Comprehensive input validation for all forms
- **Password Strength**: Minimum 6-character password requirement
- **Email Validation**: Proper email format validation

### 📱 User Experience
- **Responsive Design**: Works seamlessly across different screen sizes
- **Loading States**: Proper loading indicators during authentication
- **Error Handling**: User-friendly error messages and validation feedback
- **Navigation**: Intuitive bottom navigation with multiple sections
- **Settings → Edit Profile**: Rich profile header and settings list; edit profile supports roles, family members, dependencies and budget preferences

## Demo Account

For testing purposes, you can use the following demo account:
- **Email**: demo@example.com
- **Password**: password123

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd money_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/
│   ├── user.dart             # User + FamilyMember + Dependency models
│   └── expense.dart          # Expense model
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   ├── expense_provider.dart # Expenses + monthly budget + persistence
│   └── group_provider.dart   # Groups management (user‑scoped)
├── screens/
│   ├── login_screen.dart     # Login with validation
│   ├── signup_screen.dart    # Multi‑step registration
│   ├── dashboard_screen.dart # Main dashboard with budget section
│   ├── expenses_screen.dart  # Add/edit expenses and incomes
│   ├── groups_screen.dart    # Groups feature
│   ├── settings_screen.dart  # Settings and navigation to edit profile
│   └── account_screen.dart   # EditProfileScreen implementation
└── services/
    ├── auth_service.dart     # Auth + persisted local users DB + profile update
    └── storage_service.dart  # Per‑user expenses, groups and budget storage
```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data storage (including persisted users DB)
- **flutter_secure_storage**: Secure session/token + current user
- **http**: For future API integration
- **form_validator**: Form validation utilities

## Features in Detail

### Login Screen
- Email and password validation
- Password visibility toggle
- Loading state during authentication
- Error message display
- Link to signup screen
- Demo account information

### Signup Screen
- Full name, email, password, and confirm password fields
- Optional phone number field
- Real-time password confirmation validation
- Email format validation
- Password strength requirements

### Dashboard Screen
- User profile display with avatar
- Financial overview cards (Balance, Income, Expenses, Savings)
- Budget section respects selected user preference (Daily/Monthly/Quarterly/Individual)
- Quick action buttons for common tasks
- Recent transactions list
- Bottom navigation for different sections
- Logout functionality

### Edit Profile
- Update name, email, phone number, role in family
- Manage family members (name, relationship, monthly income, occupation)
- Manage dependencies (name, type, relationship, age, special needs)
- Select budget preferences (Daily / Monthly / Quarterly / Individual)
- All changes are persisted and reflected across the app

### Reports (Tracker Screen)
- App bar titled "Reports"
- Pie chart at the top showing category distribution of all expenses (always aggregated, unaffected by filters)
- Category filter dropdown to drill into a specific category
- Category breakdown list (respecting the filter)
- When a category is selected, a detailed list of expenses for that category is shown

## Future Enhancements

- [ ] Real backend integration (Firebase/Supabase)
- [ ] Advanced transaction management (bulk edit, recurring)
- [ ] Shared/group budgets and settlements
- [ ] Advanced analytics and forecasting
- [ ] Multiple currency support
- [ ] Export/Import data
- [ ] Push notifications
- [ ] Dark mode support

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please open an issue on the repository or contact the development team.

---

**Note**: This is a demo application with simulated authentication. In a production environment, you would integrate with a real backend service and implement proper security measures.
