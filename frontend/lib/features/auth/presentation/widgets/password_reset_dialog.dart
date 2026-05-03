import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_validators.dart';

/// Dialog for password reset — collects email and fires [onConfirm].
class PasswordResetDialog extends StatefulWidget {
  final void Function(String email) onConfirm;

  const PasswordResetDialog({super.key, required this.onConfirm});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final error = AuthValidators.validateEmail(_controller.text.trim());
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onConfirm(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: const Text('Send reset email'),
        ),
      ],
    );
  }
}
