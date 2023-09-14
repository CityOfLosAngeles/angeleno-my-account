//import 'package:angeleno_project/utils/constants.dart';

import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen2.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
//import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//flutter run -d chrome --web-port=3000 --dart-define-from-file=api-keys.json

class LoginScreen extends StatefulWidget {
  final Auth0? auth0;
  //final Auth0Web? auth0Web;
  const LoginScreen({this.auth0, final Key? key}) : super(key: key);
  //const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  //Auth0 vars
  Credentials? _credentials;
  UserProfile? _user;
  late Auth0 auth0;
  late Auth0Web auth0Web;
  static const auth0Domain = String.fromEnvironment('auth0domain');
  static const auth0ClientID = String.fromEnvironment('auth0clientID');

  @override
  void initState() {
    super.initState();

    //Initialize Auth0
    if (auth0Domain.isEmpty) {
      throw AssertionError('auth0Domain is not set');
    }

    if (auth0ClientID.isEmpty) {
      throw AssertionError('auth0ClientID is not set');
    }

    print("Auth0Web init... $auth0Domain");
    //auth0Web = Auth0Web(auth0Domain, auth0ClientID);
    auth0 = widget.auth0 ?? Auth0(auth0Domain, auth0ClientID);
    auth0Web = Auth0Web(auth0Domain, auth0ClientID);
    //auth0Web =Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

    if (kIsWeb) {
      print('KisWeb!! onLoad()');
      auth0Web
          .onLoad()
          .then((final credentials) => setState(() {
                _user = credentials?.user;
                print('The user onLoad() is $_user');
              }))
          .whenComplete(() => setState(() {
// _user = credentials?.user;
                print('The user onLoad() is $_user');
              }));
    }

/*
    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => {
            if (credentials != null)
              {
                print('The creds are $credentials')
                // Logged in!
                // auth0_flutter automatically stores the user's credentials in the
                // built-in cache.
                //
                // Access token -> credentials.accessToken
                // User profile -> credentials.user
              }
            else
              {
                // Not logged in
                print('Not logged in')
              }
          });
    }

    */
  }

  Future<void> login() async {
    try {
      if (kIsWeb) {
        print('Lets check loginWithRedirect()');
        return auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      final credentials = await auth0.webAuthentication(scheme: '').login();
      print('the credentials should have been read');
      setState(() {
        _user = credentials.user;
        _credentials = credentials;
        print('The user is $_user');
      });
    } catch (e) {
      print('Lets get into the caught state');
      print(e);
    }
  }

/*
  Future<void> login() async {
    try {
      var credentials = await auth0.webAuthentication().login();

      setState(() {
        _user = credentials.user;
        print('The user is $_user');
      });
    } on WebAuthenticationException catch (e) {
      print(e);
    }
  }
  */

  @override
  Widget build(final BuildContext context) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_credentials == null)
              ElevatedButton(onPressed: login, child: const Text("Log in"))
            else
              Column(
                children: [
                  Expanded(
                      child: Row(children: [
                    _user != null
                        ? Expanded(child: ProfileScreenAuth0(user: _user))
                        : const Expanded(child: Text('opps'))
                  ])),
                  // ProfileView(user: _credentials!.user),
                  ElevatedButton(
                      onPressed: () async {
                        /*
                        await auth0.logout(
                            returnToUrl: 'http://localhost:3000');
*/
                        await auth0.webAuthentication().logout();

                        setState(() {
                          _credentials = null;
                        });
                      },
                      child: const Text("Log out"))
                ],
              )
          ],
        ),
      );
}
