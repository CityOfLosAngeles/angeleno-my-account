import 'package:equatable/equatable.dart';

class User extends Equatable {
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

  String get fullName => '$firstName $lastName';

  @override
  String toString() =>
      '{id: $userId, email: $email, firstName: $firstName, lastName: $lastName,'
      ' zip: $zip, address: $address, city: $city, state: $state, '
        'phone: $phone}';

  // props is required for Equatable
  @override
  List<Object?> get props => [firstName, lastName,
    zip, address, city, state, phone];
}