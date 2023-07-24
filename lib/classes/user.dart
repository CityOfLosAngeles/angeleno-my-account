class User {
  int userId = -1;
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String city = '';
  String address = '';
  String zip = '';
  String state = '';

  get fullName => '$firstName $lastName';
}