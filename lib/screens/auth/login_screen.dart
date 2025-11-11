import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth/auth_service.dart';
import '../../utils/app_logger.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/theme_selector.dart';
import '../../theme/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Rive animation controllers
  StateMachineController? _controller;
  SMIInput<bool>? _isChecking;
  SMIInput<double>? _numLook;
  SMIInput<bool>? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    // Try common state machine names
    final stateMachineNames = [
      'State Machine 1',
      'Login Machine',
      'Login',
      'StateMachine',
    ];
    
    for (final name in stateMachineNames) {
      _controller = StateMachineController.fromArtboard(artboard, name);
      if (_controller != null) {
        AppLogger.info('✅ Found state machine: "$name"');
        break;
      }
    }
    
    if (_controller != null) {
      artboard.addController(_controller!);
      _isChecking = _controller?.findInput<bool>('isChecking');
      _numLook = _controller?.findInput<double>('numLook');
      _isHandsUp = _controller?.findInput<bool>('isHandsUp');
      _trigSuccess = _controller?.findSMI('trigSuccess') ?? _controller?.findSMI('trigSuil');
      _trigFail = _controller?.findSMI('trigFail');
      
      // Log what inputs were found
      if (_isChecking == null) AppLogger.warning('⚠️ "isChecking" input not found');
      if (_numLook == null) AppLogger.warning('⚠️ "numLook" input not found');
      if (_isHandsUp == null) AppLogger.warning('⚠️ "isHandsUp" input not found');
      if (_trigSuccess == null) AppLogger.warning('⚠️ "trigSuccess" trigger not found');
      if (_trigFail == null) AppLogger.warning('⚠️ "trigFail" trigger not found');
    } else {
      AppLogger.error('❌ Failed to load Rive animation controller');
      AppLogger.error('Available state machines: ${artboard.stateMachines.map((sm) => sm.name).join(", ")}');
    }
  }

  void _lookAround(String value) {
    if (_numLook != null) {
      // Scale email length to Rive's range (0-1000)
      // Multiply by 3 to make eyes move more with fewer characters
      final lookValue = (value.length * 3.0).clamp(0.0, 1000.0);
      _numLook?.change(lookValue);
    }
  }

  void _startLooking() {
    _isChecking?.change(true);
    _isHandsUp?.change(false);
  }

  void _stopLooking() {
    _isChecking?.change(false);
  }

  void _hidePassword() {
    _isHandsUp?.change(true);
  }

  void _showPassword() {
    _isHandsUp?.change(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
  
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Polar Bear Animation
              SizedBox(
                height: 250,
                child: RiveAnimation.asset(
                  'assets/polar_login_bear.riv',
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _startLooking,
                      onTapOutside: (_) => _stopLooking(),
                      onChanged: _lookAround,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _hidePassword,
                      onTapOutside: (_) => _showPassword(),
                      onEditingComplete: _showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                            if (_obscurePassword) {
                              _hidePassword();
                            } else {
                              _showPassword();
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            Icons.g_mobiledata,
                            'Google',
                            _handleGoogleLogin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSocialButton(
                            Icons.facebook,
                            'Facebook',
                            _handleFacebookLogin,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // OTP Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/auth/otp');
                        },
                        icon: const Icon(Icons.phone_android, size: 20),
                        label: const Text(
                          'Login with OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF8A9BA8)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF2B87E3),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Theme and Language Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Language Button
                        OutlinedButton.icon(
                          onPressed: () => _showLanguageDialog(context),
                          icon: const Icon(Icons.language, size: 20),
                          label: const Text('Language'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.5),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Theme Button
                        const ThemeToggleButton(),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4E5F6C), size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4E5F6C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD6E2EA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.bold,
                color: Color(0xFF4E5F6C),
              ),
            ),
            const SizedBox(height: 20),
            const LanguageSelector(showTitle: false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Bear starts checking
    _isChecking?.change(true);
    
    final authService = AuthService();
    
    AppLogger.section('🐻 BEAR LOGIN');
    
    final response = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    _isChecking?.change(false);
    
    setState(() {
      _isLoading = false;
    });

    if (response != null && response.success) {
      // Success animation - trigger fires once and auto-resets
      _trigSuccess?.fire();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Welcome back! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } else {
      // Fail animation - trigger fires once and auto-resets
      _trigFail?.fire();
      
      // Get error message from response
      String errorMessage = 'Login failed. Please check your credentials.';
      if (response != null && response.message != null && response.message!.isNotEmpty) {
        errorMessage = response.message!;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(errorMessage),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    // TODO: Implement forgot password
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Forgot password feature coming soon!'),
        ),
      );
    }
  }

  void _handleGoogleLogin() {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google login not implemented yet')),
    );
  }

  void _handleFacebookLogin() {
    // TODO: Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login not implemented yet')),
    );
  }
}
