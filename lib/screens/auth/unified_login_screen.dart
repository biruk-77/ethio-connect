import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../services/auth/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swipeable_language_selector.dart';
import '../../widgets/theme_selector.dart';
import 'register_screen.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  // OTP Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Email/Password Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _showEmailLogin = false; // Expandable email login
  bool _obscurePassword = true;
  String? _errorMessage;
  int _resendCountdown = 0;

  // Animation
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // Rive animation controllers
  StateMachineController? _controller;
  SMIInput<bool>? _isChecking;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    final stateMachineNames = ['State Machine 1', 'Login Machine', 'Login', 'StateMachine'];

    for (final name in stateMachineNames) {
      _controller = StateMachineController.fromArtboard(artboard, name);
      if (_controller != null) break;
    }

    if (_controller != null) {
      artboard.addController(_controller!);
      _isChecking = _controller?.findInput<bool>('isChecking');
      _trigSuccess = _controller?.findSMI('trigSuccess') ?? _controller?.findSMI('trigSuil');
      _trigFail = _controller?.findSMI('trigFail');
    }
  }

  void _toggleEmailLogin() {
    setState(() {
      _showEmailLogin = !_showEmailLogin;
      if (_showEmailLogin) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Future<void> _requestOTP() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _isChecking?.change(true);

    final response = await _authService.requestOTP(_phoneController.text);

    _isChecking?.change(false);

    if (response != null && response['success'] == true) {
      _trigSuccess?.fire();

      setState(() {
        _otpSent = true;
        _isLoading = false;
        _resendCountdown = 60;
      });

      _startCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('OTP sent to your phone! 📱'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _trigFail?.fire();
      setState(() {
        _isLoading = false;
        _errorMessage = response?['message'] ?? 'Failed to send OTP';
      });
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_resendCountdown > 0 && mounted) {
        setState(() => _resendCountdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _isChecking?.change(true);

    final response = await _authService.verifyOTP(
      phone: _phoneController.text,
      otp: _otpController.text,
    );

    _isChecking?.change(false);

    if (response != null && response.success) {
      _trigSuccess?.fire();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Welcome! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } else {
      _trigFail?.fire();

      String errorMessage = 'Invalid OTP code. Please try again.';
      if (response != null && response.message != null && response.message!.isNotEmpty) {
        errorMessage = response.message!;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _isChecking?.change(true);

    final response = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    _isChecking?.change(false);

    if (response != null && response.success) {
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
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } else {
      _trigFail?.fire();

      String errorMessage = 'Login failed. Please check your credentials.';
      if (response != null && response.message != null && response.message!.isNotEmpty) {
        errorMessage = response.message!;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Polar Bear Animation
                SizedBox(
                  height: 220,
                  child: RiveAnimation.asset(
                    'assets/polar_login_bear.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  'Welcome to EthioConnect',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Login with phone or email',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 32),

                // OTP Login Section (Default/Primary)
                if (!_showEmailLogin) ...[
                  // Phone Number Input
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_otpSent,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+251912345678',
                      prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // OTP Input (shown after OTP sent)
                  if (_otpSent) ...[
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'OTP Code',
                        hintText: 'Enter 6-digit code',
                        prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                            });
                          },
                          child: const Text('Change number'),
                        ),
                        TextButton(
                          onPressed: _resendCountdown == 0 ? _requestOTP : null,
                          child: Text(
                            _resendCountdown > 0 ? 'Resend in $_resendCountdown s' : 'Resend OTP',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],

                  // Action Button (Send OTP or Verify)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _requestOTP),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_otpSent ? Icons.verified : Icons.phone_android),
                                const SizedBox(width: 8),
                                Text(
                                  _otpSent ? 'Verify OTP' : 'Send OTP',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],

                // Email/Password Login Section (Expandable)
                if (_showEmailLogin) ...[
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Column(
                      children: [
                        // Email Input
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'your@email.com',
                            prefixIcon: Icon(Icons.email, color: AppColors.primary),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
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
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
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

                        const SizedBox(height: 16),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
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
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login),
                                      SizedBox(width: 8),
                                      Text(
                                        'Login with Email',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Toggle Login Method
                TextButton.icon(
                  onPressed: _toggleEmailLogin,
                  icon: Icon(
                    _showEmailLogin ? Icons.phone_android : Icons.email,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    _showEmailLogin ? 'Login with Phone' : 'Login with Email',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),

                const SizedBox(height: 16),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
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
                    const SwipeableLanguageSelector(),
                    const SizedBox(width: 12),
                    const ThemeToggleButton(),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
