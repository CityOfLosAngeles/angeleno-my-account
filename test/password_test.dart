import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/main.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {

  final userProvider = UserProvider();
  const auth0User = UserProfile(
    sub: 'auth0|id',
    email: 'user@email.com',
    givenName: 'FirstName',
    familyName: 'LastName',
    customClaims: {
      'user_metadata': {
        'addresses': {
          'primary': {
            'address': '123 Main St',
            'address2': 'Suite 200',
            'city': 'Main City',
            'state': 'Main State',
            'zip': '12345'
          }
        },
        'phone': '(555) 555-5555'
      }
    }
  );
  userProvider.setUser(auth0User);
  testWidgets('Navigates to Password', (final WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider(create: (final _) => OverlayProvider())
        ],
        child: const MyApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.ensureVisible(find.byIcon(Icons.password));
    await tester.tap(find.byIcon(Icons.password));
    await tester.pump();

    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);

    final submitButtonFinder = find.byType(ElevatedButton);
    expect(submitButtonFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(submitButtonFinder).enabled, false);

    await tester.enterText(find.byType(TextFormField).at(0), 'oldPassword');
    await tester.enterText(find.byType(TextFormField).at(1), 'newPassword123');
    await tester.enterText(find.byType(TextFormField).at(2), 'newPassword123');

    await tester.pump();
    expect(tester.widget<ElevatedButton>(submitButtonFinder).enabled, true);

    // final oldPasswordFinder = find.descendant(
    //   of: find.byKey(const Key('old_password')),
    //   matching: find.byType(TextField),
    // );

    // final field = tester.firstWidget<TextField>(oldPasswordFinder);
    // expect(field.obscureText, true);
  });
}