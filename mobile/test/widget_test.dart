// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:urbanmind_app/main.dart';
import 'package:urbanmind_app/providers/auth_provider.dart';
import 'package:urbanmind_app/providers/issue_provider.dart';

void main() {
  testWidgets('Smoke test to see if app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => IssueProvider()),
        ],
        child: const UrbanMindApp(),
      ),
    );

    // Verify successful pump by checking if a Splash Screen element exists or just completing without throw
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
