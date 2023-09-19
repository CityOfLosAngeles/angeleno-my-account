import 'package:angeleno_project/models/user.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

class UserProvider extends ChangeNotifier {
  final Auth0Web auth0Web = Auth0Web(auth0Domain, auth0ClientId);
  User? _user;
  bool _isEditing = false;

  UserProvider() {
    print('running');
    auth0Web.onLoad().then((final credentials) {
      if (credentials != null) {
        setUser(credentials.user);
      } else {
        auth0Web.loginWithRedirect(redirectUrl: redirectUri);
      }
    });
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

  void login() async {
    await auth0Web.loginWithRedirect(redirectUrl: redirectUri);
  }

  Future<bool> isLoggedIn() async =>
      await auth0Web.hasValidCredentials();

  Future<Credentials> currentCredentials() async =>
      await auth0Web.credentials();

  User? get user => _user;

  bool get isEditing => _isEditing;
}