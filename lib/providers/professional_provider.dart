import 'package:flutter/foundation.dart';

import '../core/mock/mock_data.dart';
import '../models/professional.dart';
import '../models/service.dart';
import '../models/time_slot.dart';
import '../services/professional_service.dart';

class ProfessionalProvider extends ChangeNotifier {
  final _service = ProfessionalService();

  List<Professional> _professionals = [];
  Professional? _selected;
  List<Service> _services = [];
  List<TimeSlot> _slots = [];
  bool _loading = false;
  String? _error;

  List<Professional> get professionals => _professionals;
  Professional? get selected => _selected;
  List<Service> get services => _services;
  List<TimeSlot> get slots => _slots;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProfessionals({String? category}) async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 300));
        _professionals = category == null
            ? List.from(MockData.professionals)
            : MockData.professionals
                .where((p) => p.category == category)
                .toList();
        _error = null;
        return;
      }
      _professionals = await _service.getProfessionals(category: category);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectProfessional(String id) async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 200));
        _selected = MockData.professionals.firstWhere(
          (p) => p.id == id,
          orElse: () => MockData.professionals.first,
        );
        _services =
            MockData.services.where((s) => s.professionalId == id).toList();
        _error = null;
        return;
      }
      _selected = await _service.getProfessionalById(id);
      _services = await _service.getServices(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSlots({
    required String proId,
    required String serviceId,
    required DateTime date,
  }) async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 200));
        _slots = MockData.timeSlots;
        _error = null;
        return;
      }
      _slots = await _service.getAvailableSlots(
        proId,
        serviceId: serviceId,
        date: date,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProOwnProfile(String proId) async {
    _setLoading(true);
    try {
      _selected = await _service.getProfessionalById(proId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProProfile(
    String proId, {
    required String category,
    String? bio,
  }) async {
    try {
      _selected = await _service.updateProProfile(
        proId,
        category: category,
        bio: bio,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMyServices(String proId) async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 200));
        _services =
            MockData.services.where((s) => s.professionalId == proId).toList();
        if (_services.isEmpty) _services = List.from(MockData.services.take(3));
        _error = null;
        return;
      }
      _services = await _service.getServices(proId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createService(String proId, Map<String, dynamic> body) async {
    try {
      if (kMockMode) {
        final s = Service(
          id: 'svc-new-${DateTime.now().millisecondsSinceEpoch}',
          professionalId: proId,
          name: body['name'] as String,
          description: body['description'] as String?,
          price: (body['price'] as num).toDouble(),
          durationMinutes: body['durationMinutes'] as int,
        );
        _services.add(s);
        notifyListeners();
        return true;
      }
      final s = await _service.createService(proId, body);
      _services.add(s);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService(
    String proId,
    String serviceId,
    Map<String, dynamic> body,
  ) async {
    try {
      if (kMockMode) {
        final idx = _services.indexWhere((x) => x.id == serviceId);
        if (idx != -1) {
          final old = _services[idx];
          _services[idx] = Service(
            id: old.id,
            professionalId: old.professionalId,
            name: body['name'] as String,
            description: body['description'] as String?,
            price: (body['price'] as num).toDouble(),
            durationMinutes: body['durationMinutes'] as int,
          );
        }
        notifyListeners();
        return true;
      }
      final s = await _service.updateService(proId, serviceId, body);
      final idx = _services.indexWhere((x) => x.id == serviceId);
      if (idx != -1) _services[idx] = s;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService(String proId, String serviceId) async {
    try {
      if (!kMockMode) await _service.deleteService(proId, serviceId);
      _services.removeWhere((s) => s.id == serviceId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSlots() {
    _slots = [];
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
