import '../errors/exceptions.dart';

/// Converts any exception into a human-readable French message.
class AppErrors {
  AppErrors._();

  static String friendly(Object e) {
    if (e is NetworkException) {
      return 'Pas de connexion internet. Vérifiez votre réseau.';
    }

    if (e is UnauthorizedException) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    if (e is ServerException) {
      return _fromServer(e.message, e.statusCode);
    }

    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }

  static String _fromServer(String message, int? statusCode) {
    switch (statusCode) {
      case 400:
        return _mapBadRequest(message);
      case 401:
        return 'Email ou mot de passe incorrect.';
      case 403:
        return "Vous n'avez pas l'autorisation d'effectuer cette action.";
      case 404:
        return 'Élément introuvable.';
      case 409:
        return _mapConflict(message);
      case 422:
        return 'Données invalides. Vérifiez vos informations.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Une erreur est survenue sur le serveur. Réessayez dans quelques instants.';
        }
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  static String _mapBadRequest(String message) {
    final m = message.toLowerCase();
    if (m.contains('password') || m.contains('mot de passe')) {
      return 'Le mot de passe actuel est incorrect.';
    }
    if (m.contains('email')) {
      return 'Adresse email invalide.';
    }
    if (m.contains('slot') || m.contains('créneau') || m.contains('disponib')) {
      return 'Ce créneau n\'est plus disponible. Veuillez en choisir un autre.';
    }
    return 'Données invalides. Vérifiez vos informations.';
  }

  static String _mapConflict(String message) {
    final m = message.toLowerCase();
    if (m.contains('email')) {
      return 'Cette adresse email est déjà utilisée.';
    }
    return 'Cette ressource existe déjà.';
  }
}
