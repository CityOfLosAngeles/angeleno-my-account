import 'package:angeleno_project/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_implementation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isEditing = false;

  Future<void> fetchUser(final http.Client client) async {
    _user = await UserApi().getUser(client);
    notifyListeners();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  User? get user => _user;

  bool get isEditing => _isEditing;
}