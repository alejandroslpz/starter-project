import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_validators.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/password_reset_dialog.dart';

/// Login page — allows sign in with email/password or Google.
///
/// Uses BlocConsumer:
/// - BlocBuilder: swaps CTA and disables form on AuthAuthenticating (R13).
/// - BlocListener: shows SnackBar on AuthError (R14).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (AuthValidators.validateEmail(email) != null ||
        AuthValidators.validatePassword(password) != null) {
      setState(() {}); // trigger rebuild to show inline errors
      return;
    }

    context.read<AuthBloc>().add(
          SignInWithEmailEvent(SignInParams(email: email, password: password)),
        );
  }

  void _onForgotPassword(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => PasswordResetDialog(
        onConfirm: (email) {
          context
              .read<AuthBloc>()
              .add(SendPasswordResetEvent(email));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reset email sent')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.localizedMessage)),
            );
            context.read<AuthBloc>().add(ErrorDismissedEvent());
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthAuthenticating;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    key: const Key('login_email_field'),
                    label: 'Email',
                    controller: _emailController,
                    readOnly: isLoading,
                    keyboardType: TextInputType.emailAddress,
                    errorText:
                        _emailController.text.isNotEmpty
                            ? AuthValidators.validateEmail(
                                _emailController.text)
                            : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    key: const Key('login_password_field'),
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    readOnly: isLoading,
                    errorText:
                        _passwordController.text.isNotEmpty
                            ? AuthValidators.validatePassword(
                                _passwordController.text)
                            : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          isLoading ? null : () => _onForgotPassword(context),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: () => _onSignIn(context),
                      child: const Text('Sign in'),
                    ),
                  const SizedBox(height: 12),
                  if (!isLoading)
                    GoogleSignInButton(
                      onTap: () => context
                          .read<AuthBloc>()
                          .add(SignInWithGoogleEvent()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
