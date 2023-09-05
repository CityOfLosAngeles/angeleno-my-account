// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:angeleno_project/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Loads and switches screens', (final WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (final _) => UserProvider())
        ],
        child: const MyApp()
      )
    );

    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Current Password'), findsNothing);

    await tester.tap(find.byIcon(Icons.password_outlined));
    await tester.pump();

    expect(find.text('Full Name'), findsNothing);
    expect(find.text('Current Password'), findsOneWidget);
  });
}
