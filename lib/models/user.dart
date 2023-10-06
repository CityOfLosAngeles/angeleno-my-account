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

  String get fullName => '$firstName $lastName';

  User({
      required this.userId,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.address,
      required this.city,
      required this.state,
      required this.zip,
      required this.phone,
      required this.metadata
  });

  User.copy(final User copy) :
        userId = copy.userId,
        email = copy.email,
        firstName = copy.firstName,
        lastName = copy.lastName,
        address = copy.address,
        city = copy.city,
        state = copy.state,
        zip = copy.zip,
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

  Map<String, dynamic> toJson() => {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'phone': phone,
      'metadata': metadata
    };

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