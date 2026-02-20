import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/professional.dart';
import '../models/service.dart';
import '../models/time_slot.dart';

class ProfessionalService {
  final _client = DioClient.instance;

  Future<List<Professional>> getProfessionals({String? category}) async {
    final data = await _client.get(
      ApiConstants.professionals,
      queryParams: category != null ? {'category': category} : null,
    );
    return (data as List)
        .map((e) => Professional.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Professional> getProfessionalById(String id) async {
    final data = await _client.get(ApiConstants.professionalById(id));
    return Professional.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TimeSlot>> getAvailableSlots(
    String proId, {
    required String serviceId,
    required DateTime date,
  }) async {
    final data = await _client.get(
      ApiConstants.professionalSlots(proId),
      queryParams: {
        'serviceId': serviceId,
        'date': date.toIso8601String().split('T').first,
      },
    );
    return (data as List)
        .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Professional profile
  Future<Professional> updateProProfile(
    String proId, {
    required String category,
    String? bio,
  }) async {
    final data = await _client.put(
      ApiConstants.professionalById(proId),
      data: {'category': category, 'bio': bio},
    );
    return Professional.fromJson(data as Map<String, dynamic>);
  }

  // Services CRUD
  Future<List<Service>> getServices(String proId) async {
    final data = await _client.get(ApiConstants.services(proId));
    return (data as List)
        .map((e) => Service.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Service> createService(String proId, Map<String, dynamic> body) async {
    final data = await _client.post(ApiConstants.services(proId), data: body);
    return Service.fromJson(data as Map<String, dynamic>);
  }

  Future<Service> updateService(
    String proId,
    String serviceId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.put(
      ApiConstants.serviceById(proId, serviceId),
      data: body,
    );
    return Service.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteService(String proId, String serviceId) async {
    await _client.delete(ApiConstants.serviceById(proId, serviceId));
  }

  // Availabilities CRUD
  Future<List<Map<String, dynamic>>> getAvailabilities(String proId) async {
    final data = await _client.get(ApiConstants.availabilities(proId));
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> createAvailability(
    String proId,
    Map<String, dynamic> body,
  ) async {
    final data =
        await _client.post(ApiConstants.availabilities(proId), data: body);
    return data as Map<String, dynamic>;
  }

  Future<void> deleteAvailability(String proId, String availId) async {
    await _client.delete(ApiConstants.availabilityById(proId, availId));
  }

  Future<void> setAvailabilities(
      String proId, List<Map<String, dynamic>> slots) async {
    await _client.put(
      ApiConstants.availabilities(proId),
      data: {'availabilities': slots},
    );
  }
}
