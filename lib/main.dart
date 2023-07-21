import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'classes/User.dart';

const footerBlue = Color(0xFF1f4c73);
const colorBlue = Color(0xFF0f2940);
const colorGreen = Color(0xFF03a751);
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
final actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    alignment: Alignment.center,
    textStyle: const TextStyle(
      color: Colors.black
    ),
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.black,
    shadowColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      side: BorderSide(color: Colors.black)
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
  /* Unused */
  late User user;

  final _formKey = GlobalKey<FormBuilderState>();
  static bool _isEditing = false;
  int _selectedIndex = 0;

  static bool viewPassword = false;
  static bool viewNewPassword = false;
  static bool viewPasswordMatch = false;
  late bool _isButtonDisabled;
  late String currentPassword;
  late String newPassword;
  late String passwordMatch;

  /* Proof of Concept for Data Retention on Full Name field */
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final String text = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty
      );
    });

    currentPassword = '';
    newPassword = '';
    passwordMatch = '';
    _isButtonDisabled = true;
    fetchUser(_formKey);
  }

  void _navigationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String? validatePasswords (value) =>
    (value == null || value.trim().isEmpty) ?
      'Password is required' : null;

  submitRequest() {
    if (newPassword == passwordMatch) {
      //submit request to finalize updated
    }
  }

  bool enablePasswordSubmit() {
    return !(currentPassword.trim() != "" && newPassword.trim() != ""
      && passwordMatch.trim() != "");
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
              controller: _controller
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'email',
            enabled: false,
            decoration: const InputDecoration(
                labelText: 'Email'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'first_name',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'First Name'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'last_name',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Last Name'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'zip',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Zip'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'address',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Address'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'city',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'City'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'state',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'State'
            ),
          ),
          const SizedBox(height: 25.0),
          FormBuilderTextField(
            name: 'mobile',
            enabled: _isEditing ? true : false,
            decoration: const InputDecoration(
                labelText: 'Mobile'
            ),
          ),
        ],
      ),
    ),
  );

  get passwordScreen => ListView(
    children: [
      const SizedBox(height: 5.0),
      TextFormField(
          obscureText: viewPassword ? false : true,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatePasswords,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), 
              labelText: 'Current Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    viewPassword = !viewPassword;
                  });
                }, 
                icon: Icon(viewPassword ? Icons.remove_red_eye_sharp : Icons.remove_red_eye_outlined)
              )
          ),
          onChanged: (value) {
            setState(() {
              currentPassword = value;
              _isButtonDisabled = enablePasswordSubmit();
            });
          },
          ),
      const SizedBox(height: 10.0),
      TextFormField(
          obscureText: viewNewPassword ? false : true,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatePasswords,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), 
              labelText: 'New Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    viewNewPassword = !viewNewPassword;
                  });
                }, 
                icon: Icon(viewNewPassword ? Icons.remove_red_eye_sharp : Icons.remove_red_eye_outlined)
              )
          ),
          onChanged: (value) {
            setState(() {
              newPassword = value;
              _isButtonDisabled = enablePasswordSubmit();
            });
          },
        ),
      const SizedBox(height: 10.0),
      TextFormField(
          obscureText: viewPasswordMatch ? false : true,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatePasswords,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Confirm New Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    viewPasswordMatch = !viewPasswordMatch;
                  });
                }, 
                icon: Icon(viewPasswordMatch ? Icons.remove_red_eye_sharp : Icons.remove_red_eye_outlined)
              )
          ),
          onChanged: (value) {
            setState(() {
              passwordMatch = value;
              _isButtonDisabled = enablePasswordSubmit();
            });
          },
      ),
      const SizedBox(height: 10.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _isButtonDisabled ? null : () => submitRequest(),
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

Future<void> fetchUser(formKey) async {
  // placeholder request until we get the proper endpoints and flow
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

  if (response.statusCode == HttpStatus.ok) {
    // Targeting just the first user from the placeholder endpoint [0]
    User userData = User.fromJson(jsonDecode(response.body)[0]);

    formKey.currentState?.patchValue({
      'full_name': userData.name,
      'email': userData.email,
      'first_name': userData.name.split(" ")[0],
      'last_name': userData.name.split(" ")[1],
      'zip': '',
      'address': '',
      'city': '',
      'state': '',
      'mobile': userData.phone
    });

  } else {
    throw Exception('Failed to load user data.');
  }
}


/* TO DO

- Center area so it doesn't expand to full width
- Implement loading screen?
- Review for accessibility
- Be able to Toggle password input

 */