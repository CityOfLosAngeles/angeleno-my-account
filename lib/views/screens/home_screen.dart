import 'package:angeleno_project/utils/constants.dart';
import 'package:angeleno_project/views/nav/app_bar.dart';
import 'package:angeleno_project/views/screens/password_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_provider.dart';
import 'login_screen.dart';

class MyHomePage extends StatefulWidget {
  final Auth0? auth0;
  //const MyHomePage({super.key});
  const MyHomePage({this.auth0, final Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UserProvider userProvider;
  int _selectedIndex = 0;
  UserProfile? user;

  late Auth0 auth0;
  late Auth0Web auth0Web;
  Credentials? _credentials;
  UserProfile? _user;

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
      auth0Web.onLoad().then((final credentials) {
            _user = credentials?.user;
            var something = _user!.email;
            print('The user onLoad() is $something');
          });
    }
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
        const LoginScreen(),
        const ProfileScreen(
            // user: user,
            ),
        const PasswordScreen(),
        //Security
        ListView(
          children: const [Text('This looks like an external script.')],
        ),
      ];

  @override
  Widget build(final BuildContext context) {
    final bool smallScreen = MediaQuery.of(context).size.width < 720;
    userProvider = context.watch<UserProvider>();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 47.0, 0, 0),
      child: Scaffold(
          appBar: const MainAppBar(),
          body: Container(
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
                                onDestinationSelected: _navigationSelected,
                                destinations: const <NavigationRailDestination>[
                                NavigationRailDestination(
                                    icon: Icon(Icons.login),
                                    selectedIcon:
                                        Icon(Icons.login, color: Colors.white),
                                    label: Text('Login')),
                                NavigationRailDestination(
                                    icon: Icon(Icons.person_outline_outlined),
                                    selectedIcon:
                                        Icon(Icons.person, color: Colors.white),
                                    label: Text('Profile')),
                                NavigationRailDestination(
                                    icon: Icon(Icons.password_outlined),
                                    selectedIcon: Icon(Icons.password,
                                        color: Colors.white),
                                    label: Text('Password')),
                                NavigationRailDestination(
                                    icon: Icon(Icons.lock_outline),
                                    selectedIcon:
                                        Icon(Icons.lock, color: Colors.white),
                                    label: Text('Security')),
                              ])),
                    Expanded(
                        flex: 8,
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: screens[_selectedIndex]))
                  ],
                ),
              )),
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
                          icon: Icon(Icons.password_outlined),
                          label: 'Password'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.lock_outline), label: 'Security'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.login), label: 'Login')
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
                  ))),
    );
  }
}
