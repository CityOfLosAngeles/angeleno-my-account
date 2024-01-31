// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'dart:convert';
import 'package:angeleno_project/controllers/user_provider.dart';
import 'package:angeleno_project/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:angeleno_project/main.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {

  testWidgets('Loads user', (final WidgetTester tester) async {

    await tester.pumpWidget(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (final _) => UserProvider())
            ],
            child: const MyApp()
        )
    );

    // ignore: unused_local_variable
    final client = MockClient(
      (final request) async {
        final response = {
            'id': 1,
            'name': 'Leanne Graham',
            'username': 'Bret',
            'email': 'Sincere@april.biz',
            'address': {
              'street': 'Kulas Light',
              'city': 'Gwenborough',
              'zipcode': '92998-3874',
            },
            'phone': '1-770-736-8031 x56442',
        };

        return http.Response(jsonEncode(response), 200);
      }
    );

    final userProvider = UserProvider();
    expect(userProvider.user, isA<User>());

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Current Password'), findsNothing);


    final Finder iconButton = find.byType(IconButton);
    await tester.tap(iconButton);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.password));
    await tester.pump();

    expect(find.text('Full Name'), findsNothing);
    expect(find.text('Current Password'), findsOneWidget);
  });
}