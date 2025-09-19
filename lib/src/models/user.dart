enum UserType { consumer, supplier, foodBank }

class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      type: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}