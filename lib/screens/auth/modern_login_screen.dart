import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Modern Login Screen with curved gradient background
/// Inspired by the provided design screenshot
class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Curved gradient background
          _buildCurvedBackground(context),

          // Main content
          SafeArea(
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),

                      // Welcome section with modern styling
                      _buildWelcomeSection(context),

                      const SizedBox(height: 60),

                      // Login card with glassmorphism effect
                      _buildLoginCard(context, authService),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Curved gradient background like in the screenshot
  Widget _buildCurvedBackground(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xFF006E1F), // Solid dark green
      ),
      child: CustomPaint(painter: CurvePainter()),
    );
  }

  // Welcome section with modern design
  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        // App title with white color for visibility on gradient background
        Text(
          'Welcome',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Lorem ipsum dolor sit amet consectetur,\nLorem sit',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Login card with glassmorphism effect
  Widget _buildLoginCard(BuildContext context, AuthService authService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sign in header
              Text(
                'Sign in',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightOnSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),

              // Email Field with modern styling
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'demo@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field with modern styling
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Remember me and forgot password row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed:
                        () => _showForgotPasswordDialog(context, authService),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Error Message
              if (authService.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    authService.error!,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Login Button with gradient
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF006E1F), // Solid dark green
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006E1F).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed:
                      authService.isLoading
                          ? null
                          : () => _handleEmailSignIn(authService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      authService.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an Account? ",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/register');
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEmailSignIn(AuthService authService) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Clear previous errors
        authService.clearError();

        final success = await authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          if (context.mounted) {
            // Show success message briefly
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome back!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
            context.go('/');
          }
        }
        // If not successful, error message will already be shown via authService.error
      } catch (e) {
        // This should rarely happen as AuthService handles most errors
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showForgotPasswordDialog(
    BuildContext context,
    AuthService authService,
  ) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your email address to receive a password reset link.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty) {
                    try {
                      final success = await authService.resetPassword(
                        emailController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent! Please check your inbox.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          // Show the specific error from AuthService
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authService.error ??
                                    'Failed to send reset email',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    // Show validation error for empty email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your email address'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: const Text('Send Reset Email'),
              ),
            ],
          ),
    );
  }
}

// Custom painter for the curved background effect
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white.withOpacity(0.1);
    paint.style = PaintingStyle.fill;

    var path = Path();

    // Create the curved shape like in the screenshot
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.65,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
