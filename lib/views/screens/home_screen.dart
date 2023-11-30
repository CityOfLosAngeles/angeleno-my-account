import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/views/screens/password_screen.dart';
import 'package:angeleno_project/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/user_provider.dart';
import '../../models/user.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late UserProvider userProvider;
  late User user;
  late OverlayProvider overlayProvider;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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

  Future<void> _navigationSelected(final int index) async {

    if (userProvider.isEditing && index != 0) {
      _unsavedDataDialog(index);
    } else {
      // Could use a cleaner implementation
      if ([3, 4, 5].contains(index)) {
        switch(index) {
          case 3:
            await launchUrl(
              Uri.parse('https://angeleno.lacity.org/')
            );
            break;
          case 4:
            await launchUrl(
              Uri.parse('https://angeleno.lacity.org/apps')
            );
            break;
          case 5:
            await launchUrl(
              Uri.parse('https://angeleno.lacity.org/help')
            );
            break;
        }
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }

    scaffoldKey.currentState!.closeDrawer();
  }

  List<Widget> get screens => <Widget>[
        const ProfileScreen(),
        const PasswordScreen(),
        //Security
        ListView(
          children: const [Text('This looks like an external script.')],
        )
      ];

  @override
  Widget build(final BuildContext context) {
     var userEmail = '';
     overlayProvider = Provider.of<OverlayProvider>(context);
     userProvider = context.watch<UserProvider>();
     if (userProvider.user != null) {
       user = userProvider.user!;
       userEmail = user.email;
     }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 47.0, 0, 0),
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
              title: const Text('Angeleno Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
          ),
          drawer: NavigationDrawer(
            onDestinationSelected: _navigationSelected,
            selectedIndex: _selectedIndex,
            children:  <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Text('My Account - $userEmail'),
              ),
              const NavigationDrawerDestination(
                  label: Text('Profile'),
                  icon: Icon(Icons.person)
              ),
              const NavigationDrawerDestination(
                  label: Text('Password'),
                  icon: Icon(Icons.password)
              ),
              const NavigationDrawerDestination(
                  label: Text('Security'),
                  icon: Icon(Icons.security)
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Text('Angeleno'),
              ),
              const NavigationDrawerDestination(
                  label: Text('Home'),
                  icon: Icon(Icons.home)
              ),
              const NavigationDrawerDestination(
                  label: Text('Services'),
                  icon: Icon(Icons.grid_view)
              ),
              const NavigationDrawerDestination(
                  label: Text('Help'),
                  icon: Icon(Icons.question_mark)
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                child: Divider(),
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
                  child: Container(
                    transformAlignment: Alignment.center,
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: screens[_selectedIndex]))
                      ],
                    ),
                  )
              ),
              if (overlayProvider.isLoading)
                Center(
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 1280),
                    padding: const EdgeInsets.fromLTRB(
                        10, 0, 10, 0
                    ),
                    color: Colors.black.withOpacity(0.25),
                    child: const LinearProgressIndicator(),
                  )
                ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16.0),
            child: const Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  '© Copyright 2023 City of Los Angeles. '
                  'All rights reserved. Disclaimer | Privacy Policy',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                )
              ],
            )
          )
      ),
    );
  }
}
