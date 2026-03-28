import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../components/transparent_text_field.dart';
import '../../components/auth_button.dart';
import '../../components/auth_link.dart';
import '../../components/auth_error_message.dart';
import '../../utils/custom_snackbar.dart';

/// Modern Login Screen with clean design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();

    // Clear any previous errors when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/welcome-coins.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7)),
          child: Consumer<AuthService>(
            builder: (context, authService, child) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App Title
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Sign in to continue your financial journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 48),
                              ],
                            ),
                          ),

                          // Login Form
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildLoginForm(context, authService),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Sign up option
                          AuthLink(
                            question: "Don't have an account? ",
                            linkText: 'Sign Up',
                            onTap: () => context.push('/register'),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TransparentTextField(
            controller: _emailController,
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password Field
          TransparentTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Error Message
          AuthErrorMessage(error: authService.error),

          // Sign In Button
          AuthButton(
            text: 'Sign In',
            onPressed: () => _handleSignIn(authService),
            isLoading: authService.isEmailLoading,
            isPrimary: true,
          ),

          const SizedBox(height: 16),

          // Forgot Password
          GestureDetector(
            onTap: () => _showForgotPasswordDialog(authService),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: RichText(
                text: const TextSpan(
                  text: 'Forgot your password? ',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Reset it here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(AuthService authService) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      final success = await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (success) {
        context.go('/');
      } else {
        _showError(authService.error ?? 'Sign-in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showError(_friendlyError(e));
    }
  }

  void _showError(String message) {
    if (message.isEmpty) return;
    CustomSnackBar.showError(context, message);
  }

  void _showForgotPasswordDialog(AuthService authService) {
    final emailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surface
                : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                CustomSnackBar.showError(context, 'Please enter a valid email');
                return;
              }
              Navigator.pop(ctx);
              final success = await authService.resetPassword(email);
              if (mounted) {
                if (success) {
                  CustomSnackBar.showSuccess(
                    context,
                    'Reset link sent! Check your email.',
                  );
                } else {
                  CustomSnackBar.showError(
                    context,
                    authService.error ?? 'Failed to send reset email.',
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  String _friendlyError(dynamic e) {
    final s = e.toString().toLowerCase();
    if (s.contains('network') || s.contains('socket') || s.contains('timeout')) {
      return 'No internet connection. Please check your WiFi or mobile data.';
    }
    return 'Sign-in failed. Please try again.';
  }
}
