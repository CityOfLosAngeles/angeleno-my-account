import 'package:angeleno_project/models/constants.dart';
import 'package:angeleno_project/views/screens/password_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var constants = Constants();

  late User user;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // fetchUser(formKey);
  }

  void _navigationSelected(final int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get screens => <Widget>[
    const ProfileScreen(),
    const PasswordScreen(),
    //Security
    ListView(
      children: const [
        Text('This looks like an external script.')
      ],
    )
  ];

  @override
  Widget build(final BuildContext context) {
    final bool smallScreen = MediaQuery.of(context).size.width < 720;
    print('Rebuilding');
    
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 47.0, 0, 0),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: constants.colorGreen,
            title: const Text('Angeleno Account',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            actions:
            <Widget>[
              ElevatedButton.icon(
                  onPressed: () async {
                    await launchUrl(
                        Uri.parse('https://angeleno.lacity.org/')
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white,),
                  label: const Text('Home',
                      style: TextStyle(color: Colors.white)
                  ),
                  style: constants.angelenoAccountButtonStyle
              ),
              const SizedBox(width: 5.0),
              ElevatedButton.icon(
                  onPressed: () async {
                    await launchUrl(
                        Uri.parse('https://angeleno.lacity.org/apps')
                    );
                  },
                  icon: const Icon(Icons.grid_view_rounded,
                      color: Colors.white
                  ),
                  label: const Text('Services',
                      style: TextStyle(color: Colors.white)
                  ),
                  style: constants.angelenoAccountButtonStyle
              ),
              const SizedBox(width: 5.0),
              ElevatedButton.icon(
                  onPressed: () async {
                    await launchUrl(
                        Uri.parse('https://angeleno.lacity.org/help')
                    );
                  },
                  icon: const Icon(Icons.question_mark, color: Colors.white,),
                  label: const Text('Help',
                      style: TextStyle(color: Colors.white)
                  ),
                  style: constants.angelenoAccountButtonStyle
              ),
              const SizedBox(width: 5.0),
            ],
      ),
          body: Container(
          transformAlignment: Alignment.center,
          /*
          **  Add constraints when we figure out how to center
          */
          // constraints: const BoxConstraints(minWidth: 700, maxWidth: 1000),
          child: Center(
            child: Row(
              children: <Widget>[
                smallScreen ? const SizedBox.shrink() : Expanded(
                    flex: 2,
                    child:
                    NavigationRail(
                        selectedIndex: _selectedIndex,
                        labelType: NavigationRailLabelType.none,
                        extended: true,
                        indicatorColor: constants.colorBlue,
                        onDestinationSelected: _navigationSelected,
                        destinations: const <NavigationRailDestination> [
                          NavigationRailDestination(
                              icon: Icon(Icons.person_outline_outlined),
                              selectedIcon: Icon(Icons.person,
                                  color: Colors.white
                              ),
                              label: Text('Profile')
                          ),
                          NavigationRailDestination(
                              icon: Icon(Icons.password_outlined),
                              selectedIcon: Icon(Icons.password,
                                  color: Colors.white
                              ),
                              label: Text('Password')
                          ),
                          NavigationRailDestination(
                              icon: Icon(Icons.lock_outline),
                              selectedIcon: Icon(Icons.lock,
                                  color: Colors.white
                              ),
                              label: Text('Security')
                          )
                        ]
                    )
                ),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: screens[_selectedIndex]
                    )
                )
              ],
            ),
          )

        ),
          bottomNavigationBar: smallScreen ?
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: constants.colorBlue,
              onTap: _navigationSelected,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_outlined),
                    label: 'Profile'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.password_outlined),
                    label: 'Password'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.lock_outline),
                    label: 'Security'
                )
              ]
          ) : Container(
               color: constants.footerBlue,
               padding: const EdgeInsets.all(16.0),
               child: const Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text('© Copyright 2023 City of Los Angeles. '
                       'All rights reserved. Disclaimer | Privacy Policy',
                     style: TextStyle(color: Colors.white)
                   )
                 ],
              )
            )
      ),
    );
  }
}

// Future<void> fetchUser(final GlobalKey<FormBuilderState> formKey) async {
//   // placeholder request until we get the proper endpoints and flow
//   final response = await http.get(
//       Uri.parse('https://jsonplaceholder.typicode.com/users')
//   );
//
//   if (response.statusCode == HttpStatus.ok) {
//     // Targeting just the first user from the placeholder endpoint [0]
//     final String rawJson = response.body;
//     final jsonMap = jsonDecode(rawJson)[0];
//
//     formKey.currentState?.patchValue({
//       'full_name': jsonMap['name'],
//       'email': jsonMap['email'],
//       'first_name': jsonMap['name'].split(' ')[0],
//       'last_name': jsonMap['name'].split(' ')[1],
//       'zip': '',
//       'address': '',
//       'city': '',
//       'state': '',
//       'mobile': jsonMap['phone']
//     });
//
//   } else {
//     throw Exception('Failed to load user data.');
//   }
// }