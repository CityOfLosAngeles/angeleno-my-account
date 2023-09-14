import 'package:angeleno_project/models/user.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';

import 'api_implementation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isEditing = false;

  Future<void> fetchUser() async {
    _user = await UserApi().getUser('');
    notifyListeners();
  }

  void setUser(final UserProfile user) {
    _user = User(
        userId: user.sub,
        email: user.email,
        firstName: user.name ?? '',
        lastName: user.familyName ?? '',
        zip: user.address?[''],
        address: user.address?[''],
        city: user.address?[''],
        state: user.address?[''],
        phone: user.phoneNumber
    );

    notifyListeners();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  User? get user => _user;

  bool get isEditing => _isEditing;
}