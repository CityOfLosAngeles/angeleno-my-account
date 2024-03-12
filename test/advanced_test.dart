import 'package:angeleno_project/controllers/api_implementation.dart';
import 'package:angeleno_project/controllers/overlay_provider.dart';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/main.dart';
import 'package:angeleno_project/models/api_response.dart';
import 'package:angeleno_project/views/screens/advanced_security_screen.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'mocks/advanced_test.mocks.dart';

@GenerateMocks([UserApi])
void main() {

  late MockUserApi userApi;

  setUp(() {
    userApi = MockUserApi();
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
    final mockResponse = ApiResponse(200, '[{"type": "totp", "id": "123"}]');

    when(userApi.getAuthenticationMethods(any))
      .thenAnswer((_) async => mockResponse);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider(create: (final _) => OverlayProvider())
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.security));
    await tester.pump();

    expect(find.byType(AdvancedSecurityScreen), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('enableAuthenticator')), findsOneWidget);
    await tester.tap(find.byKey( const Key('enableAuthenticator')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  });
}