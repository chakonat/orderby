class Address {
  Address({
    required this.id,
    required this.label,
    required this.city,
    required this.street,
    required this.building,
    required this.apartment,
    required this.comment,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String city;
  final String street;
  final String building;
  final String apartment;
  final String comment;
  final bool isDefault;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] as String,
      label: (json['label'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      street: (json['street'] ?? '') as String,
      building: (json['building'] ?? '') as String,
      apartment: (json['apartment'] ?? '') as String,
      comment: (json['comment'] ?? '') as String,
      isDefault: (json['isDefault'] ?? false) as bool,
    );
  }
}
