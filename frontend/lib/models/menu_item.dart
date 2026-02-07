class MenuItem {
  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.calories,
    required this.imageUrl,
    required this.isPopular,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String category;
  final int price;
  final int calories;
  final String imageUrl;
  final bool isPopular;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] as String,
      restaurantId: json['restaurant'] as String,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      price: (json['price'] ?? 0) as int,
      calories: (json['calories'] ?? 0) as int,
      imageUrl: (json['imageUrl'] ?? '') as String,
      isPopular: (json['isPopular'] ?? false) as bool,
    );
  }
}
