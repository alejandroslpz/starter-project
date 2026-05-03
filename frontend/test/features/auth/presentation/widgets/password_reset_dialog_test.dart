import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/password_reset_dialog.dart';

void main() {
  group('PasswordResetDialog', () {
    testWidgets('renders email text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordResetDialog(onConfirm: (_) {}),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('fires onConfirm callback with email when confirmed',
        (tester) async {
      String? capturedEmail;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordResetDialog(
              onConfirm: (email) => capturedEmail = email,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.tap(find.text('Send reset email'));
      await tester.pump();

      expect(capturedEmail, equals('test@example.com'));
    });
  });
}
