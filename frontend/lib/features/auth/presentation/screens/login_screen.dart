import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/features/auth/presentation/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthBloc bloc) {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    bloc.add(
      AuthSignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.failure != null && current.failure != previous.failure,
        listener: (context, state) {
          final failure = state.failure!;
          final isFieldError =
              failure is ValidationFailure && failure.fieldErrors.isNotEmpty;
          if (isFieldError) return;
          showAppSnack(context, failure.message, isError: true);
        },
        builder: (context, state) {
          final submitting = state.isSubmitting;
          final fieldErrors = state.fieldErrors;
          return Stack(
            children: [
              const AuthBackdrop(),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: MediaQuery.paddingOf(context).top + 24,
                      ),
                      const AuthBrand(
                        subtitle: 'Welcome back, sign in to continue',
                      ),
                      const SizedBox(height: 32),
                      AuthCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'john@example.com',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
validator: (value) => fieldErrors['email']?.first ??
                                  (value == null || value.trim().isEmpty
                                      ? 'Enter your email'
                                      : null),
                                errorText: fieldErrors['email']?.first,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    fieldErrors['password']?.first ??
                                    (value == null || value.isEmpty
                                        ? 'Enter your password'
                                        : null),
                                errorText: fieldErrors['password']?.first,
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.hint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Sign In',
                        icon: Icons.login_rounded,
                        isLoading: submitting,
                        onPressed: submitting
                            ? null
                            : () => _submit(context.read<AuthBloc>()),
                      ),
                      const SizedBox(height: 14),
                      AuthToggleRow(
                        prompt: "Don't have an account?",
                        linkLabel: 'Register here',
                        onLink: () => context.go('/register'),
                      ),
                      SizedBox(
                        height: 24 + MediaQuery.paddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}