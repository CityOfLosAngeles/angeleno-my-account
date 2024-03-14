import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/models/api_response.dart';
import 'package:angeleno_project/views/screens/advanced_security_screen.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'mocks/advanced_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserApi>()])
void main() {

  late MockUserApi mockUserApi;

  setUp(() {
    mockUserApi = MockUserApi();
  });

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

  testWidgets('Navigates to Advanced Security', (final WidgetTester tester) async {
    final authenticationMethodsMockResponse = ApiResponse(200, '[{"type": "totp", "id": "123"}]');
    final disableAuthenticatorMockResponse = ApiResponse(200, '');

    when(mockUserApi.getAuthenticationMethods(any))
        .thenAnswer((_) async => authenticationMethodsMockResponse);

    when(mockUserApi.unenrollMFA(any))
        .thenAnswer((_) async => disableAuthenticatorMockResponse);

    await tester.pumpWidget(
MaterialApp(
        home: Scaffold(
          body: AdvancedSecurityScreen(
              userProvider: userProvider,
              userApi: mockUserApi
          ),
        )
      ),
    );

    await tester.pumpAndSettle();
    verify(mockUserApi.getAuthenticationMethods(any)).called(1);

    // Mock response has Authenticator enabled
    // so the UI should reflect disable button
    expect(find.byKey(const Key('disableAuthenticator')), findsOneWidget);
    await tester.tap(find.byKey( const Key('disableAuthenticator')));

    await tester.pumpAndSettle();

    // Opens dialog and closes it on Cancel
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    // Disables Authenticator
    await tester.tap(find.byKey( const Key('disableAuthenticator')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Ok'));
    await tester.pumpAndSettle();

    // Should find the button to enable Authenticator
    expect(find.byKey(const Key('enableAuthenticator')), findsOneWidget);
    await tester.tap(find.byKey( const Key('enableAuthenticator')));

    await tester.pumpAndSettle();

    // Enrollment Dialog
    expect(find.byType(Dialog), findsOneWidget);

    // Enters password and taps submit
    // await tester.enterText(find.byType(TextFormField), 'userPassword');
    // await tester.tap(find.byType(TextButton));
    // await tester.pumpAndSettle();
  });
}