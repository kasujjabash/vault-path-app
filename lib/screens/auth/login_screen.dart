import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../components/transparent_text_field.dart';
import '../../components/auth_button.dart';
import '../../components/auth_divider.dart';
import '../../components/auth_link.dart';
import '../../components/auth_error_message.dart';

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
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
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
                              children: [
                                const Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Sign in to continue your financial journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
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
                color: Colors.white.withOpacity(0.7),
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

          const SizedBox(height: 32),

          // Error Message
          AuthErrorMessage(error: authService.error),

          // Sign In Button
          AuthButton(
            text: 'Sign In',
            onPressed: () => _handleSignIn(authService),
            isLoading: authService.isEmailLoading,
            isPrimary: true,
          ),

          const SizedBox(height: 24),

          // Divider
          const AuthDivider(),

          const SizedBox(height: 24),

          // Google Sign In Button
          AuthButton(
            text: 'Continue with Google',
            onPressed: () => _handleGoogleSignIn(authService),
            isLoading: authService.isGoogleLoading,
            isPrimary: false,
            icon: const FaIcon(
              FontAwesomeIcons.google,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(AuthService authService) async {
    try {
      if (_formKey.currentState!.validate()) {
        final success = await authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (success && mounted) {
          if (context.mounted) context.go('/');
        }
      }
    } catch (e) {
      debugPrint('Error during email sign-in: $e');
      // AuthService already handles error display, so we don't need to show additional error here
      if (mounted) {
        // Optionally show a snackbar for critical errors that slip through
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthService authService) async {
    try {
      final success = await authService.signInWithGoogle();
      if (success && mounted) {
        if (context.mounted) context.go('/');
      }
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      // AuthService already handles error display, so we don't need to show additional error here
      if (mounted) {
        // Optionally show a snackbar for critical errors that slip through
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-in failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
