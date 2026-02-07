class Promo {
  Promo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    required this.discountPercent,
  });

  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
  final int discountPercent;

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['_id'] as String,
      title: json['title'] as String,
      subtitle: (json['subtitle'] ?? '') as String,
      badge: (json['badge'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      discountPercent: (json['discountPercent'] ?? 0) as int,
    );
  }
}
