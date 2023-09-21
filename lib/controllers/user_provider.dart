import 'package:angeleno_project/models/user.dart';
import 'package:flutter/foundation.dart';

import 'api_implementation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isEditing = false;

  Future<void> fetchUser() async {
    _user = await UserApi().getUser('');
    notifyListeners();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  User? get user => _user;

  bool get isEditing => _isEditing;
}