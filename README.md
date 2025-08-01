# Money Manager

A comprehensive Flutter application for personal finance management with secure authentication, modern UI, and intuitive user experience.

## Features

### 🔐 Authentication System
- **Secure Login**: Email and password authentication with proper validation
- **User Registration**: Complete signup process with form validation
- **Session Management**: Persistent login state using secure storage
- **Demo Account**: Pre-configured demo account for testing

### 💰 Financial Dashboard
- **Balance Overview**: Real-time display of total balance, income, expenses, and savings
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
│   └── user.dart            # User data model
├── providers/
│   └── auth_provider.dart   # Authentication state management
├── screens/
│   ├── login_screen.dart    # Login screen with validation
│   ├── signup_screen.dart   # Registration screen
│   └── dashboard_screen.dart # Main dashboard with financial overview
└── services/
    └── auth_service.dart    # Authentication logic and user management
```

## Dependencies

- **provider**: State management for authentication
- **shared_preferences**: Local data storage
- **flutter_secure_storage**: Secure storage for sensitive data
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
- Quick action buttons for common tasks
- Recent transactions list
- Bottom navigation for different sections
- Logout functionality

## Future Enhancements

- [ ] Real database integration (Firebase/Supabase)
- [ ] Transaction management (add/edit/delete)
- [ ] Budget planning and tracking
- [ ] Financial reports and analytics
- [ ] Multiple currency support
- [ ] Export functionality
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
