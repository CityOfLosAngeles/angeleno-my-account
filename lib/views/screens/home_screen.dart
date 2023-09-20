import 'dart:js_interop';

import 'package:angeleno_project/utils/constants.dart';
import 'package:angeleno_project/views/nav/app_bar.dart';
import 'package:angeleno_project/views/screens/password_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen3.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_provider.dart';
import 'login_screen.dart';

class MyHomePage extends StatefulWidget {
  // final Auth0? auth0;
  const MyHomePage({super.key});
  //const MyHomePage({this.auth0, final Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UserProvider userProvider;
  int _selectedIndex = 0;
  UserProfile? user;
  late Future auth0Future;

  //late Auth0 auth0;
  late Auth0Web auth0Web;
  //Credentials? _credentials;
  UserProfile? _user;
  //late bool isLoggedIn;

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

    auth0Web = Auth0Web(auth0Domain, auth0ClientID);
    // auth0 = Auth0(auth0Domain, auth0ClientID);
    print('Init first?');
    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => {
            if (credentials != null)
              {
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
                print('Not Logged in, lets init'),
              }
          });
    }
    auth0Future = auth0Login();
    /* if (kIsWeb) {
      print('About to auth0login');
      auth0Login();
    }*/
/*
    if (kIsWeb) {
      print('KisWeb!! onLoad()');
      auth0Web.onLoad().then((final credentials) {
        _user = credentials?.user;
        print('The user onLoad() is ${_user!.email}');
      });
    }
    */
  }
/*
  void initCred() async {
    Credentials? creds;
    bool isLoggedIn = false;

    try {
      creds = await auth0Web.credentials();
      print('Lets get isloggedin');
      isLoggedIn = await auth0Web.hasValidCredentials();
    } catch (e) {
      print('The error is ${e.toString()}');
      auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
    }
  }*/

  Future<UserProfile?> auth0Login() async {
    print('Future first?');
    print('Lets get credsZZZ');
    // UserProfile? u;
    //Credentials? creds;

    if (!auth0Web.isNull) {
      print('Auth0We is not Null');
      print('Anything after this is not Printing.... =/');

      try {
        //First we gotta see that the credentials exist if they are not present we receive an ""need to login" error
        final creds = await auth0Web.credentials();
        if (creds != null) {
          print('The credzzESDS are ${creds.user.email}');
        }
      } catch (e) {
        print('The error is $e.toString()');
      }

      final isLoggedIn = await auth0Web.hasValidCredentials();

      print('What is IsLoggedIn?! $isLoggedIn');

      if (isLoggedIn) {
        print('We should be logged in! $isLoggedIn');
        final creds = await auth0Web.credentials();
        print('The credzz are ${creds.user.email}');
        _user = creds.user;
        return creds.user;
      } else {
        print('Not logged in!');
        await auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      /*
      auth0Web.onLoad().then((final credentials) => setState(() {
            // Handle or store credentials here
            //isLoggedIn = await auth0Web.hasValidCredentials();
            if (credentials != null) {
              creds = credentials;
            } else {
              print('user IS STILL NULL');
            }
          }));

      */

      //Credentials? creds = await auth0Web.credentials();
    }
    //Credentials? creds = await auth0Web.credentials();
    // bool? isLoggedIn = await auth0Web.hasValidCredentials() ?? false;
    return _user;
  }

  Future<UserProfile?> auth0Loginold() async {
    print('Lets get creds');

    Credentials? creds;
    bool isLoggedIn = false;
    try {
      //creds = await auth0Web.credentials();
      print('Lets get isloggedin');
      isLoggedIn = await auth0Web.hasValidCredentials();
    } catch (e) {
      print('The error is ${e.toString()}');
      auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
    }
    //if we are logged in, let's make sure we set the credentials
    if (isLoggedIn) {
      print('Did we reach isLoggedIn? Yes!!! $isLoggedIn');
      /*if (creds != null) {
        print(
            'The user is not empty!! Yay! ${creds.user.email} and isLoggedIn $isLoggedIn');
        _user = creds.user;
        return _user;
        //return creds.user;
      } else {
        print('No creds yet foo!!! and isLoggedIn $isLoggedIn');
      }*/
    } else //Otherwise let's redirect to login
    {
      auth0Web.onLoad().then((final credentials) => setState(() {
            try {
              _user = credentials?.user;
              // return _user;
              print('The user is ${_user!.email}');
            } catch (e) {
              print('The error onload is $e');
            }
          }));
    }

    return _user;
  }

  Future<void> _unsavedDataDialog(final int futureIndex) async =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) => AlertDialog(
          title: const Text('You have unsaved changes'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your changes have not been saved. Discard changes?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                userProvider.toggleEditing();
                setState(() {
                  _selectedIndex = futureIndex;
                });
              },
            ),
          ],
        ),
      );

  void _navigationSelected(final int index) {
    if (userProvider.isEditing && index != 0) {
      _unsavedDataDialog(index);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget> get screens => <Widget>[
        //const LoginScreen(),
        ProfileScreen3(user: _user),
        const PasswordScreen(),
        //Security
        ListView(
          children: const [Text('This looks like an external script.')],
        ),
      ];

/*
  Future<String> getData() => Future.delayed(const Duration(seconds: 2), () {
        return 'I am data';
        // throw Exception("Custom Error");
      });
      */

  @override
  Widget build(final BuildContext context) {
    final bool smallScreen = MediaQuery.of(context).size.width < 720;
    userProvider = context.watch<UserProvider>();

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(0, 47, 0, 0),
      child: Scaffold(
        appBar: const MainAppBar(),
        body: FutureBuilder(
          builder: (ctx, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                //final data = snapshot.data as String;
                return Container(
                    transformAlignment: Alignment.center,
                    /*
          **  Add constraints when we figure out how to center
          */
                    // constraints: const BoxConstraints(minWidth: 700, maxWidth: 1000),
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          smallScreen
                              ? const SizedBox.shrink()
                              : Expanded(
                                  child: NavigationRail(
                                      selectedIndex: _selectedIndex,
                                      labelType: NavigationRailLabelType.all,
                                      indicatorColor: colorGreen,
                                      onDestinationSelected:
                                          _navigationSelected,
                                      destinations: const <NavigationRailDestination>[
                                      /*NavigationRailDestination(
                                    icon: Icon(Icons.login),
                                    selectedIcon:
                                        Icon(Icons.login, color: Colors.white),

                                    label: Text('Login')),
                                    */
                                      NavigationRailDestination(
                                          icon: Icon(
                                              Icons.person_outline_outlined),
                                          selectedIcon: Icon(Icons.person,
                                              color: Colors.white),
                                          label: Text('Profile')),
                                      NavigationRailDestination(
                                          icon: Icon(Icons.password_outlined),
                                          selectedIcon: Icon(Icons.password,
                                              color: Colors.white),
                                          label: Text('Password')),
                                      NavigationRailDestination(
                                          icon: Icon(Icons.lock_outline),
                                          selectedIcon: Icon(Icons.lock,
                                              color: Colors.white),
                                          label: Text('Security')),
                                    ])),
                          Expanded(
                              flex: 8,
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: screens[_selectedIndex]))
                        ],
                      ),
                    ));
              }
            }

            // Displaying LoadingSpinner to indicate waiting state
            return const Center(
              child: CircularProgressIndicator(),
            );
          },

          // Future that needs to be resolved
          // inorder to display something on the Canvas
          future: auth0Future,
        ),
        bottomNavigationBar: smallScreen
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                selectedItemColor: colorGreen,
                unselectedItemColor: colorGrey,
                onTap: _navigationSelected,
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_outlined),
                        label: 'Profile'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.password_outlined), label: 'Password'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.lock_outline), label: 'Security'),
                    /*BottomNavigationBarItem(
                          icon: Icon(Icons.login), label: 'Login')*/
                  ])
            : Container(
                color: footerBlue,
                padding: const EdgeInsets.all(16.0),
                child: const Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      '© Copyright 2023 City of Los Angeles. '
                      'All rights reserved. Disclaimer | Privacy Policy',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.ltr,
                    )
                  ],
                ),
              ),
      ),
    );
  }

  //}
}
