import 'package:flutter_test/flutter_test.dart';
import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
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

  testWidgets('Loads AppBar Title', (final WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (final _) => UserProvider()),
          ChangeNotifierProvider(create: (final _) => OverlayProvider())
        ],
        child: const MyApp(),
      ),
    );
    expect(find.text('Angeleno Account'), findsOneWidget);
  });

  testWidgets('Displays User', (final WidgetTester tester) async {
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

    expect(find.text('Angeleno Account'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(userProvider.isEditing, true);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(userProvider.isEditing, false);

    await tester.enterText(find.byType(TextFormField).at(0), 'New First Name');
    await tester.pump();

    expect(userProvider.user!.firstName, 'New First Name');
  });
}