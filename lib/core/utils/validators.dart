/// Validation utilities for form inputs.
class Validators {
  Validators._();

  /// Validates Vietnamese phone number format.
  /// Accepts formats: 0912345678, +84912345678, 84912345678
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final pattern = RegExp(r'^(\+?84|0)(3|5|7|8|9)[0-9]{8}$');

    if (!pattern.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates OTP code format (6 digits).
  static String? otpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the OTP code';
    }

    if (value.trim().length != 6 || int.tryParse(value.trim()) == null) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  /// Normalizes phone number to E.164 format (+84...).
  static String normalizePhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '+84${cleaned.substring(1)}';
    } else if (cleaned.startsWith('84') && !cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+84$cleaned';
    }

    return cleaned;
  }
}
