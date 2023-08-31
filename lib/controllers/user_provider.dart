import 'package:angeleno_project/models/user.dart';
import 'package:flutter/foundation.dart';

import 'api_implementation.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  Future<void> fetchUser() async {
    _user = await UserApi().getUser('');
    notifyListeners();
  }

  User? get user => _user;
}