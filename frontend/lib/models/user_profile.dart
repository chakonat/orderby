import 'address.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.addresses,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final List<Address> addresses;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final addressList = (json['addresses'] as List? ?? [])
        .map((item) => Address.fromJson(item as Map<String, dynamic>))
        .toList();

    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: (json['email'] ?? '') as String,
      addresses: addressList,
    );
  }
}
