class User {
  late String userId;
  late String email;
  late String firstName;
  late String lastName;
  late String zip;
  late String address;
  late String city;
  late String state;
  late String phone;

   User({
      required this.userId,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.zip,
      required this.address,
      required this.city,
      required this.state,
      required this.phone
  });

  factory User.fromJson(final Map<String, String> json) => User(
      userId: json['id'].toString(),
      email: json['email'].toString(),
      firstName: json['name']!.split(' ')[0].toString(),
      lastName: json['name']!.split(' ')[1].toString(),
      zip: json['address'].toString(),
      address: json['address'].toString(),
      city: json['address'].toString(),
      state: json['address'].toString(),
      phone: json['phone'].toString()
    );

  String get fullName => '$firstName $lastName';

  @override
  String toString() =>
      '{id: $userId, email: $email, firstName: $firstName, lastName: $lastName,'
      ' zip: $zip, address: $address, city: $city, state: $state, '
        'phone: $phone}';
}