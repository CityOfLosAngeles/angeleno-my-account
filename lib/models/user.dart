class User {
  late String userId;
  late String? email;
  late String? firstName;
  late String? lastName;
  late String? zip;
  late String? address;
  late String? city;
  late String? state;
  late String? phone;

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

  String get fullName => '$firstName $lastName';

  @override
  String toString() =>
      '{id: $userId, email: $email, firstName: $firstName, lastName: $lastName,'
      ' zip: $zip, address: $address, city: $city, state: $state, '
        'phone: $phone}';
}