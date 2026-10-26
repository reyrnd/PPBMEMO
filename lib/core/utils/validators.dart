class Validators {
  const Validators._();

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) return requiredError;

    final normalizedValue = value!.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(normalizedValue)) {
      return 'Format email tidak valid.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, 'Password');
    if (requiredError != null) return requiredError;

    final passwordValue = value!;
    if (passwordValue.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(passwordValue)) {
      return 'Password harus memiliki huruf besar.';
    }
    if (!RegExp(r'\d').hasMatch(passwordValue)) {
      return 'Password harus memiliki angka.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final requiredError = required(value, 'Konfirmasi password');
    if (requiredError != null) return requiredError;

    if (value != original) {
      return 'Konfirmasi password belum cocok.';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi.';
    }
    return null;
  }
}
