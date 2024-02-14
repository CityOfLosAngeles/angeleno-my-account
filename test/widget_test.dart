import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:angeleno_project/main.dart';
import 'package:provider/provider.dart';

void main() {

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

  group('OverlayProvider', () {
    test('Test overlay initialization', () {
      final overlayProvider = OverlayProvider();
      expect(overlayProvider.isLoading, false);
    });

    test('Test showing overlay', () {
      final overlayProvider = OverlayProvider();
      overlayProvider.showLoading();
      expect(overlayProvider.isLoading, true);
    });
  });

  testWidgets('Loads AppBar Title', (final WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (final _) => UserProvider()),
          ChangeNotifierProvider(create: (final _) => OverlayProvider())
        ],
        child: const MyApp()
      )
    );

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.text('Angeleno Account'), findsOneWidget);
  });

  testWidgets('Displays and edits user', (final WidgetTester tester) async {
    final userProvider = UserProvider();
    userProvider.setUser(auth0User);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider(create: (final _) => OverlayProvider())
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump(const Duration());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('First Name'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(userProvider.isEditing, true);

    await tester.enterText(find.byType(TextFormField).at(0), 'New First Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'New Last Name');
    await tester.enterText(find.byType(TextFormField).at(2), '(555)555-5555');
    await tester.enterText(find.byType(TextFormField).at(3), 'New Address');
    await tester.enterText(find.byType(TextFormField).at(4), 'New Address 2');
    await tester.enterText(find.byType(TextFormField).at(5), 'New City');
    await tester.enterText(find.byType(TextFormField).at(6), 'New State');
    await tester.enterText(find.byType(TextFormField).at(7), 'New Zip');

    await tester.dragUntilVisible(
      find.text('Save'),
      find.byType(ElevatedButton),
      const Offset(-250, 0),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(userProvider.isEditing, false);
    expect(userProvider.user!.firstName, 'New First Name');
    expect(userProvider.user!.lastName, 'New Last Name');
    expect(userProvider.user!.phone, '(555)555-5555');
    expect(userProvider.user!.address, 'New Address');
    expect(userProvider.user!.address2, 'New Address 2');
    expect(userProvider.user!.city, 'New City');
    expect(userProvider.user!.state, 'New State');
    expect(userProvider.user!.zip, 'New Zip');

  });

  testWidgets('Navigates to Password', (final WidgetTester tester) async {
    final userProvider = UserProvider();
    userProvider.setUser(auth0User);

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

    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    expect(tester.widget<ElevatedButton>(buttonFinder).enabled, false);

    await tester.enterText(find.byType(TextFormField).at(0), 'oldPassword');
    await tester.enterText(find.byType(TextFormField).at(1), 'newPassword123');
    await tester.enterText(find.byType(TextFormField).at(2), 'newPassword123');

    await tester.pump();
    expect(tester.widget<ElevatedButton>(buttonFinder).enabled, true);
  });
}