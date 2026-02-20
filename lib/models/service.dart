class Service {
  final String id;
  final String professionalId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;

  const Service({
    required this.id,
    required this.professionalId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
  });

  String get formattedPrice => '${price.toStringAsFixed(2)} €';
  String get formattedDuration => '$durationMinutes min';

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as String,
        professionalId: json['professionalId'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        durationMinutes: json['durationMinutes'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professionalId': professionalId,
        'name': name,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
      };
}
