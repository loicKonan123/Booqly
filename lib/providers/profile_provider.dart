import 'package:flutter/foundation.dart';

import '../services/user_service.dart';
import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final _service = UserService();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> updateProfile({
    required AuthProvider auth,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final updated = await _service.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      await auth.updateUser(updated);
      _error = null;
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('Exception:')) {
      return msg.split('Exception:').last.trim();
    }
    return msg;
  }
}
