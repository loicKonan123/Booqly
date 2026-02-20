import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

class UserService {
  final _client = DioClient.instance;

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final data = await _client.put(ApiConstants.profile, data: {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    });
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put(ApiConstants.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
