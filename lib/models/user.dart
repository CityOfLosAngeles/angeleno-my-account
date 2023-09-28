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
  late Map<String, dynamic>? metadata;

   User({
      required this.userId,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.zip,
      required this.address,
      required this.city,
      required this.state,
      required this.phone,
      required this.metadata
  });

  User.copy(final User copy) :
        userId = copy.userId,
        email = copy.email,
        firstName = copy.firstName,
        lastName = copy.lastName,
        zip = copy.zip,
        address = copy.address,
        city = copy.city,
        state = copy.state,
        phone = copy.phone,
        metadata = copy.metadata;

  @override
  bool operator ==(final Object other) => other is User &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.zip == zip &&
      other.address == address &&
      other.city == city &&
      other.phone == phone &&
      other.state == state;

  String get fullName => '$firstName $lastName';

  @override
  String toString() =>
      '{id: $userId, email: $email, firstName: $firstName, lastName: $lastName,'
      ' zip: $zip, address: $address, city: $city, state: $state, '
        'phone: $phone}';

  @override
  int get hashCode => firstName.hashCode ^ lastName.hashCode ^
    zip.hashCode ^ address.hashCode ^ city.hashCode ^ state.hashCode ^
    phone.hashCode;


}