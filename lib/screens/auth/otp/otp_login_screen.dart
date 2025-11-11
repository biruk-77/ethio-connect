import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import '../../../services/auth/auth_service.dart';
import '../../../utils/app_logger.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/theme_selector.dart';
import '../../../widgets/language_selector.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({super.key});

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  
  // Rive animation controllers
  StateMachineController? _controller;
  SMIInput<bool>? _isChecking;
  SMIInput<double>? _numLook;
  SMIInput<bool>? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
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
    }
  }

  void _lookAround(String value) {
    if (_numLook != null) {
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

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

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
        setState(() {
          _resendCountdown--;
        });
        _startCountdown();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter OTP code';
      });
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
      AppLogger.success('✅ OTP verified successfully');
      
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
      
      // Get error message from response
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface.withOpacity(0.7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
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
                  _otpSent ? 'Enter OTP Code' : 'Phone Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  _otpSent
                      ? 'We sent a code to ${_phoneController.text}'
                      : 'We\'ll send you a verification code',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Phone input
                if (!_otpSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    onTap: _startLooking,
                    onTapOutside: (_) => _stopLooking(),
                    onChanged: _lookAround,
                    decoration: InputDecoration(
                      hintText: '+251912345678',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.white,
                      prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+251')) {
                        return 'Phone must start with +251';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Request OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestOTP,
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
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
                
                // OTP input
                if (_otpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      letterSpacing: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.white,
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
                      counterText: '',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
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
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend OTP
                  TextButton(
                    onPressed: _resendCountdown > 0 ? null : _requestOTP,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend OTP in ${_resendCountdown}s'
                          : 'Resend OTP',
                      style: TextStyle(
                        color: _resendCountdown > 0 
                            ? theme.colorScheme.onSurfaceVariant 
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Edit phone number
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Change Phone Number'),
                  ),
                ],
                
                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
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
                
                // Login with email
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/auth/login');
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text(
                      'Login with Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Theme and Language Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    const ThemeToggleButton(),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
}
