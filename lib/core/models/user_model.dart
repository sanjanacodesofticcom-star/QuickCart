class UserAddress {
  final String id;
  final String title;
  final String line1;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.title,
    required this.line1,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  String get fullAddress => '$line1, $city, $state - $pincode';

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Home',
      line1: json['line1'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'line1': line1,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final List<UserAddress> addresses;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    this.addresses = const [],
  });

  UserAddress? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((a) => UserAddress.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }
}
