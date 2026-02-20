import 'package:hive/hive.dart';

import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

class AuthService {
  final _client = DioClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    await _saveTokens(data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    final data = await _client.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
    });
    await _saveTokens(data);
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } finally {
      await _clearTokens();
    }
  }

  Future<User?> getStoredUser() async {
    final box = Hive.box(ApiConstants.authBox);
    final raw = box.get(ApiConstants.userKey);
    if (raw == null) return null;
    return User.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  String? getAccessToken() {
    final box = Hive.box(ApiConstants.authBox);
    return box.get(ApiConstants.accessTokenKey) as String?;
  }

  bool get isAuthenticated {
    return getAccessToken() != null;
  }

  Future<void> _saveTokens(dynamic data) async {
    final box = Hive.box(ApiConstants.authBox);
    final map = data as Map<String, dynamic>;
    await box.put(ApiConstants.accessTokenKey, map['accessToken']);
    await box.put(ApiConstants.refreshTokenKey, map['refreshToken']);
    if (map['user'] != null) {
      await box.put(ApiConstants.userKey, map['user']);
    }
  }

  Future<void> _clearTokens() async {
    final box = Hive.box(ApiConstants.authBox);
    await box.delete(ApiConstants.accessTokenKey);
    await box.delete(ApiConstants.refreshTokenKey);
    await box.delete(ApiConstants.userKey);
  }
}
