import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../core/constants/api_constants.dart';
import '../core/mock/mock_data.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  User? _user;
  bool _loading = false;
  bool _initialized = false; // true une fois que Hive a été lu au démarrage
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get initialized => _initialized;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isProfessional => _user?.isProfessional ?? false;

  AuthProvider() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    if (kMockMode) {
      _user = MockData.clientUser;
      _initialized = true;
      notifyListeners();
      return;
    }
    _user = await _service.getStoredUser();
    if (_service.getAccessToken() == null) _user = null;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final data = await _service.login(email: email, password: password);
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    _setLoading(true);
    try {
      final data = await _service.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (kMockMode) return; // No-op in mock mode
    await _service.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Called by ProfileProvider after a successful profile update.
  Future<void> updateUser(User updated) async {
    _user = updated;
    final box = Hive.box(ApiConstants.authBox);
    await box.put(ApiConstants.userKey, updated.toJson());
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
