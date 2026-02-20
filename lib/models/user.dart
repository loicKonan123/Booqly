class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role; // 'client' | 'professional'
  final String? professionalId; // Guid du profil Professional (pros uniquement)

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.professionalId,
  });

  bool get isProfessional => role == 'professional';
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String,
        professionalId: json['professionalId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role,
        'professionalId': professionalId,
      };
}
