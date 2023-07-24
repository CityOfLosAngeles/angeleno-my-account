import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'classes/user.dart';

const footerBlue = Color(0xFF1f4c73);
const colorBlue = Color(0xFF0f2940);
const colorGreen = Color(0xFF03a751);
final _formKey = GlobalKey<FormBuilderState>();
final angelenoAccountButtonStyle =  ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
    overlayColor: MaterialStateProperty.all<Color>(const Color(0xff0daa58)),
    alignment: Alignment.center,
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      )
    )
);
final actionButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
    overlayColor: MaterialStateProperty.all<Color>(const Color(0xfff6f6f6)),
    alignment: Alignment.center,
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            side: BorderSide(color: Colors.black)
        )
    )
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angeleno - Account',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late User user;
  late bool loading = true;
  static bool _isEditing = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    fetchUser().then((value) {
      setState(() {
        user = value;
        loading = false;
      });
    });
  }

  void _navigationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static String _currentPassword = '',
    _newPassword = '',
    _passwordMatch = '';

  /* Unused */
  // Would like to replace the `validator`
  // on each TextFormField with a single function if possible
  validatePasswords (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  get profileScreen => FormBuilder(
    key: _formKey,
    onChanged: () {
      _formKey.currentState!.save();
    },
    autovalidateMode: AutovalidateMode.disabled,
    skipDisabled: true,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  style: actionButtonStyle,
                  child: Text(_isEditing ? 'Save' : 'Edit'),
                )
              ]
          ),
          const SizedBox(height: 10.0),
          FormBuilderTextField(
              name: 'full_name',
              enabled: false,
              decoration: const InputDecoration(
                  labelText: 'Full Name'
              ),
              initialValue: user.fullName,
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'email',
            enabled: false,
            decoration: const InputDecoration(
                labelText: 'Email'
            ),
            initialValue: user.email,
            onChanged: (val) {
              user.email = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'first_name',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'First Name'
            ),
            initialValue: user.firstName,
            onChanged: (val) {
              user.firstName = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'last_name',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Last Name'
            ),
            initialValue: user.lastName,
            onChanged: (val) {
              user.lastName = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'zip',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Zip'
            ),
            initialValue: user.zip,
            onChanged: (val) {
              user.zip = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'address',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Address'
            ),
            initialValue: user.address,
            onChanged: (val) {
              user.address = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'city',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'City'
            ),
            initialValue: user.city,
            onChanged: (val) {
              user.city = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'state',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'State'
            ),
            initialValue: user.state,
            onChanged: (val) {
              user.state = val!;
            },
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'mobile',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Mobile'
            ),
            initialValue: user.phone,
            onChanged: (val) {
              user.phone = val!;
            },
          ),
        ],
      ),
    ),
  );

  get passwordScreen => ListView(
    children: [
      const SizedBox(height: 5.0),
      TextFormField(
          initialValue: _currentPassword,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Current Password')),
      const SizedBox(height: 10.0),
      TextFormField(
          initialValue: _newPassword,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'New Password')),
      const SizedBox(height: 10.0),
      TextFormField(
          initialValue: _passwordMatch,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Confirm New Password'
          )
      ),
      const SizedBox(height: 10.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: actionButtonStyle,
            child: const Text('Change Password'),
          )
        ],
      )

    ],
  );

  List<Widget> get screens => <Widget>[
    profileScreen,
    passwordScreen,
    //Security
    ListView(
      children: const [
        Text('This looks like an external script.')
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    bool smallScreen = MediaQuery.of(context).size.width < 720;
    print('Rebuilding');
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorBlue,
        leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SvgPicture.asset(
                'images/los_angeles_seal.svg',
                semanticsLabel: 'Los Angeles Seal'
            )
        ),
        title: const Text('Los Angeles', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Opens https://myla311.lacity.org/ in a new window',
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://www.myla311.lacity.org'),
                  mode: LaunchMode.externalApplication
              );
            },
            icon: const Icon(Icons.add_ic_call_outlined),
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Opens https://lacity.gov/directory in a new window',
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://www.lacity.gov/directory/'),
                  mode: LaunchMode.externalApplication
              );
            },
            icon: const Icon(Icons.location_city_outlined),
            color: Colors.white,
          )
        ],
      ),
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: colorGreen,
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
                      Uri.parse('https://angeleno.lacity.org/'),
                      mode: LaunchMode.platformDefault
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white,),
                  label: const Text('Home', style: TextStyle(color: Colors.white)),
                  style: angelenoAccountButtonStyle
                 ),
                const SizedBox(width: 5.0),
                ElevatedButton.icon(
                  onPressed: () async {
                    await launchUrl(
                        Uri.parse('https://angeleno.lacity.org/apps'),
                        mode: LaunchMode.platformDefault
                    );
                  },
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white,),
                  label: const Text('Services', style: TextStyle(color: Colors.white)),
                  style: angelenoAccountButtonStyle
                ),
                const SizedBox(width: 5.0),
                ElevatedButton.icon(
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse('https://angeleno.lacity.org/help'),
                          mode: LaunchMode.platformDefault
                      );
                    },
                    icon: const Icon(Icons.question_mark, color: Colors.white,),
                    label: const Text('Help', style: TextStyle(color: Colors.white)),
                    style: angelenoAccountButtonStyle
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
                        indicatorColor: colorBlue,
                        onDestinationSelected: _navigationSelected,
                        destinations: const <NavigationRailDestination> [
                          NavigationRailDestination(
                              icon: Icon(Icons.person_outline_outlined),
                              selectedIcon: Icon(Icons.person, color: Colors.white),
                              label: Text('Profile')
                          ),
                          NavigationRailDestination(
                              icon: Icon(Icons.password_outlined),
                              selectedIcon: Icon(Icons.password, color: Colors.white),
                              label: Text('Password')
                          ),
                          NavigationRailDestination(
                              icon: Icon(Icons.lock_outline),
                              selectedIcon: Icon(Icons.lock, color: Colors.white),
                              label: Text('Security')
                          )
                        ]
                    )
                ),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: loading ? null : screens[_selectedIndex]
                    )
                )
              ],
            ),
          )

        ),
        bottomNavigationBar: smallScreen ?
          BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: colorBlue,
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
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Text("© Copyright 2023 City of Los Angeles. All rights reserved. Disclaimer | Privacy Policy", style: TextStyle(color: Colors.white),)
                 ],
              )
            )


      ),
    );
  }

}

Future<User> fetchUser() async {
  // placeholder request until we get the proper endpoints and flow
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

  if (response.statusCode == HttpStatus.ok) {
    // Targeting just the first user from the placeholder endpoint [0]
    final data = jsonDecode(response.body)[0];

    User user = User();
    user.email = data["email"];
    user.firstName = data["name"].toString().split(" ")[0];
    user.lastName = data["name"].toString().split(" ")[1];
    user.phone = data["phone"];
    user.address = data["address"]["street"];
    user.zip = data["address"]["zipcode"];
    user.city = data["address"]["city"];

    return user;
  } else {
    throw Exception('Failed to load user data.');
  }
}