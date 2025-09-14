class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  // Phone number validation (basic)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  // Amount validation
  static bool isValidAmount(String amount) {
    final parsed = double.tryParse(amount);
    return parsed != null && parsed > 0;
  }

  // Get validation error message
  static String? getEmailError(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? getPasswordError(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? getNameError(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(name)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? getPhoneError(String? phone) {
    if (phone != null && phone.isNotEmpty && !isValidPhoneNumber(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? getAmountError(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }
    if (!isValidAmount(amount)) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? getConfirmPasswordError(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
