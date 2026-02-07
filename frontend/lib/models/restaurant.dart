class Restaurant {
  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisine,
    required this.imageUrl,
    required this.city,
    required this.rating,
    required this.priceLevel,
    required this.deliveryTime,
    required this.minOrder,
    required this.deliveryFee,
    required this.tags,
  });

  final String id;
  final String name;
  final String description;
  final String cuisine;
  final String imageUrl;
  final String city;
  final double rating;
  final String priceLevel;
  final String deliveryTime;
  final int minOrder;
  final int deliveryFee;
  final List<String> tags;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      cuisine: (json['cuisine'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      rating: (json['rating'] ?? 0).toDouble(),
      priceLevel: (json['priceLevel'] ?? '₸₸') as String,
      deliveryTime: (json['deliveryTime'] ?? '') as String,
      minOrder: (json['minOrder'] ?? 0) as int,
      deliveryFee: (json['deliveryFee'] ?? 0) as int,
      tags: (json['tags'] as List? ?? []).map((tag) => tag.toString()).toList(),
    );
  }
}
