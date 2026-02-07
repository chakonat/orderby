class OrderSummary {
  OrderSummary({
    required this.id,
    required this.restaurantName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String restaurantName;
  final int total;
  final String status;
  final DateTime createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>? ?? {};
    return OrderSummary(
      id: json['_id'] as String,
      restaurantName: (restaurant['name'] ?? 'Restaurant') as String,
      total: (json['total'] ?? 0) as int,
      status: (json['status'] ?? 'created') as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
