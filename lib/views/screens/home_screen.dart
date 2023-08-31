import 'package:angeleno_project/utils/constants.dart';
import 'package:angeleno_project/views/nav/app_bar.dart';
import 'package:angeleno_project/views/screens/password_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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
                smallScreen ? const SizedBox.shrink() : Expanded(
                    child:
                    NavigationRail(
                        selectedIndex: _selectedIndex,
                        labelType: NavigationRailLabelType.all,
                        indicatorColor: colorGreen,
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
              selectedItemColor: colorGreen,
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
               color: footerBlue,
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