class Professional {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? category;
  final String? avatarUrl;
  final double? rating;
  final int reviewCount;

  const Professional({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.category,
    this.avatarUrl,
    this.rating,
    this.reviewCount = 0,
  });

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  factory Professional.fromJson(Map<String, dynamic> json) => Professional(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        bio: json['bio'] as String?,
        category: json['category'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        reviewCount: (json['reviewCount'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'bio': bio,
        'category': category,
        'avatarUrl': avatarUrl,
        'rating': rating,
        'reviewCount': reviewCount,
      };
}
