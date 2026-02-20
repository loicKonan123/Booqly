class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? required(String? value, {String label = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est requis';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Téléphone requis';
    final regex = RegExp(r'^\+?[\d\s\-]{8,15}$');
    if (!regex.hasMatch(value.trim())) return 'Numéro invalide';
    return null;
  }

  static String? positiveNumber(String? value, {String label = 'Valeur'}) {
    if (value == null || value.trim().isEmpty) return '$label requis';
    final num = double.tryParse(value.trim());
    if (num == null || num <= 0) return '$label doit être positif';
    return null;
  }
}
