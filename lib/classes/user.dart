class User {
  late int userId;
  late String name;
  late String username;
  late String email;
  late String phone;

   User({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
    required this.phone
  });

  factory User.fromJson(final Map<String, dynamic> json) => User(
      userId: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? ''
    );
}