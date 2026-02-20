import '../../models/appointment.dart';
import '../../models/professional.dart';
import '../../models/service.dart';
import '../../models/time_slot.dart';
import '../../models/user.dart';

/// Activer / désactiver le mode mock
const bool kMockMode = false;

class MockData {
  MockData._();

  // ── Utilisateurs ─────────────────────────────────────────────
  static const clientUser = User(
    id: 'client-1',
    email: 'thomas@example.com',
    firstName: 'Thomas',
    lastName: 'Dubois',
    phone: '+33 6 12 34 56 78',
    role: 'client',
  );

  static const proUser = User(
    id: 'pro-1',
    email: 'sophie@example.com',
    firstName: 'Sophie',
    lastName: 'Martin',
    phone: '+33 6 98 76 54 32',
    role: 'professional',
  );

  // ── Professionnels ────────────────────────────────────────────
  static final professionals = <Professional>[
    const Professional(
      id: 'pro-1',
      firstName: 'Sophie',
      lastName: 'Martin',
      email: 'sophie@example.com',
      phone: '+33 6 98 76 54 32',
      bio: 'Coiffeuse professionnelle avec 10 ans d\'expérience. Spécialisée en colorations et coupes tendance.',
      category: 'Coiffure',
      rating: 4.8,
      reviewCount: 124,
    ),
    const Professional(
      id: 'pro-2',
      firstName: 'Lucas',
      lastName: 'Bernard',
      email: 'lucas@example.com',
      phone: '+33 6 11 22 33 44',
      bio: 'Massothérapeute certifié. Massage suédois, shiatsu et drainage lymphatique.',
      category: 'Bien-être',
      rating: 4.9,
      reviewCount: 87,
    ),
    const Professional(
      id: 'pro-3',
      firstName: 'Camille',
      lastName: 'Petit',
      email: 'camille@example.com',
      phone: '+33 6 55 44 33 22',
      bio: 'Coach de vie et développement personnel. Accompagnement individuel et en groupe.',
      category: 'Coaching',
      rating: 4.7,
      reviewCount: 56,
    ),
    const Professional(
      id: 'pro-4',
      firstName: 'Antoine',
      lastName: 'Moreau',
      email: 'antoine@example.com',
      phone: '+33 6 77 88 99 00',
      bio: 'Ostéopathe D.O. Prise en charge des douleurs musculo-squelettiques.',
      category: 'Santé',
      rating: 4.6,
      reviewCount: 203,
    ),
    const Professional(
      id: 'pro-5',
      firstName: 'Léa',
      lastName: 'Rousseau',
      email: 'lea@example.com',
      phone: '+33 6 33 22 11 00',
      bio: 'Esthéticienne diplômée. Soins du visage, épilation, manucure et onglerie.',
      category: 'Beauté',
      rating: 4.9,
      reviewCount: 341,
    ),
  ];

  // ── Services ──────────────────────────────────────────────────
  static final services = <Service>[
    // Sophie - Coiffure
    const Service(id: 'svc-1', professionalId: 'pro-1', name: 'Coupe femme', price: 45, durationMinutes: 60, description: 'Coupe, shampoing et coiffage inclus'),
    const Service(id: 'svc-2', professionalId: 'pro-1', name: 'Coloration complète', price: 80, durationMinutes: 90, description: 'Couleur + soin + coiffage'),
    const Service(id: 'svc-3', professionalId: 'pro-1', name: 'Balayage', price: 120, durationMinutes: 120, description: 'Balayage naturel ou californien'),
    // Lucas - Massage
    const Service(id: 'svc-4', professionalId: 'pro-2', name: 'Massage suédois', price: 70, durationMinutes: 60),
    const Service(id: 'svc-5', professionalId: 'pro-2', name: 'Massage relaxant', price: 55, durationMinutes: 45),
    const Service(id: 'svc-6', professionalId: 'pro-2', name: 'Drainage lymphatique', price: 90, durationMinutes: 75),
    // Camille - Coaching
    const Service(id: 'svc-7', professionalId: 'pro-3', name: 'Séance découverte', price: 0, durationMinutes: 30, description: 'Premier entretien offert'),
    const Service(id: 'svc-8', professionalId: 'pro-3', name: 'Séance individuelle', price: 80, durationMinutes: 60),
    // Antoine - Ostéo
    const Service(id: 'svc-9', professionalId: 'pro-4', name: 'Consultation ostéo', price: 65, durationMinutes: 45),
    // Léa - Esthétique
    const Service(id: 'svc-10', professionalId: 'pro-5', name: 'Soin visage', price: 60, durationMinutes: 60),
    const Service(id: 'svc-11', professionalId: 'pro-5', name: 'Manucure', price: 35, durationMinutes: 45),
    const Service(id: 'svc-12', professionalId: 'pro-5', name: 'Pose gel', price: 55, durationMinutes: 75),
  ];

  // ── Rendez-vous ───────────────────────────────────────────────
  static final _now = DateTime.now();

  static final appointments = <Appointment>[
    Appointment(
      id: 'rdv-1',
      clientId: 'client-1',
      clientName: 'Thomas Dubois',
      clientPhone: '+33 6 12 34 56 78',
      professional: professionals[0],
      service: services[1],
      startTime: _now.add(const Duration(days: 2, hours: 10)),
      endTime: _now.add(const Duration(days: 2, hours: 11, minutes: 30)),
      status: 'confirmed',
      notes: 'Première visite, cheveux longs',
    ),
    Appointment(
      id: 'rdv-2',
      clientId: 'client-1',
      clientName: 'Thomas Dubois',
      clientPhone: '+33 6 12 34 56 78',
      professional: professionals[1],
      service: services[3],
      startTime: _now.add(const Duration(days: 5, hours: 14)),
      endTime: _now.add(const Duration(days: 5, hours: 15)),
      status: 'pending',
    ),
    Appointment(
      id: 'rdv-3',
      clientId: 'client-1',
      clientName: 'Thomas Dubois',
      clientPhone: '+33 6 12 34 56 78',
      professional: professionals[2],
      service: services[7],
      startTime: _now.subtract(const Duration(days: 7, hours: 11)),
      endTime: _now.subtract(const Duration(days: 7, hours: 10)),
      status: 'completed',
    ),
    Appointment(
      id: 'rdv-4',
      clientId: 'client-1',
      clientName: 'Thomas Dubois',
      clientPhone: '+33 6 12 34 56 78',
      professional: professionals[4],
      service: services[10],
      startTime: _now.subtract(const Duration(days: 14, hours: 15)),
      endTime: _now.subtract(const Duration(days: 14, hours: 14, minutes: 15)),
      status: 'cancelled',
    ),
    Appointment(
      id: 'rdv-5',
      clientId: 'client-2',
      clientName: 'Marie Leroy',
      clientPhone: '+33 6 00 11 22 33',
      professional: professionals[0],
      service: services[0],
      startTime: _now.add(const Duration(days: 1, hours: 9)),
      endTime: _now.add(const Duration(days: 1, hours: 10)),
      status: 'confirmed',
    ),
  ];

  // ── Créneaux horaires ─────────────────────────────────────────
  static List<TimeSlot> get timeSlots {
    final base = DateTime.now().add(const Duration(days: 3));
    final day = DateTime(base.year, base.month, base.day, 9, 0);
    return [
      for (int i = 0; i < 8; i++)
        TimeSlot(
          id: 'slot-$i',
          startTime: day.add(Duration(hours: i)),
          endTime: day.add(Duration(hours: i, minutes: 45)),
          isAvailable: i != 2 && i != 5,
        ),
    ];
  }
}
