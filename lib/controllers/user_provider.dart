import 'dart:html' as html;
import 'package:angeleno_project/models/user.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

class UserProvider extends ChangeNotifier {
  final Auth0Web auth0Web = Auth0Web(auth0Domain, auth0ClientId);
  User? _user;
  User? _cleanUser;
  bool _isEditing = false;

  UserProvider() {
    print('running');
    auth0Web.onLoad().then((final credentials) async {
      if (credentials != null) {
        html.window.history.pushState(null, 'home', '/');
        setUser(credentials.user);
        _cleanUser = User.copy(_user!);
      } else {
        await auth0Web.loginWithRedirect(redirectUrl: redirectUri);
      }
    });
  }

  void setUser(final UserProfile user) {
    final metadata = user.customClaims!['user_metadata']
                                  as Map<String, dynamic>;
    final primaryAddress = metadata['addresses']?['primary'];

    _user = User(
        userId: user.sub,
        email: user.email,
        firstName: user.name ?? '',
        lastName: user.familyName ?? '',
        zip: primaryAddress['zip'] as String,
        address: primaryAddress['address'] as String,
        city: primaryAddress['city'] as String,
        state: primaryAddress['state'] as String,
        phone: user.phoneNumber,
        metadata: metadata
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

  User? get cleanUser => _cleanUser;

  bool get isEditing => _isEditing;
}