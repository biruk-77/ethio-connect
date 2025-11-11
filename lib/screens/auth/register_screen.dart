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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final Set<String> _selectedRoles = {'user'}; // User is default
  
  // Rive animation controllers
  StateMachineController? _controller;
  SMIInput<bool>? _isChecking;
  SMIInput<double>? _numLook;
  SMIInput<bool>? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    // Make bear look left/right based on input length
    if (_numLook != null) {
      // Scale input length to Rive's range (0-100)
      // Multiply by 3 to make eyes move more with fewer characters
      final lookValue = (value.length * 3.0).clamp(0.0, 100.0);
      _numLook?.change(lookValue);
      AppLogger.info('👀 Looking: ${value.length} chars → value: $lookValue');
    } else {
      AppLogger.warning('⚠️ _numLook is null - animation not initialized');
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Bear starts checking
    _isChecking?.change(true);
    
    final authService = AuthService();
    
    AppLogger.section('🐻 BEAR REGISTRATION');
    
    // Use first selected role (API expects single role)
    final role = _selectedRoles.first;
    
    final response = await authService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      role: role,
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Welcome ${_usernameController.text}! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate to home
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } else {
      // Fail animation - trigger fires once and auto-resets
      _trigFail?.fire();
      
      // Get error message from response
      String errorMessage = 'Registration failed. Please try again.';
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
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E5F6C),
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Join EthioConnect today!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8A9BA8),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _startLooking,
                      onTapOutside: (_) => _stopLooking(),
                      onChanged: _lookAround,
                      decoration: InputDecoration(
                        hintText: 'Username', // TODO: Add to localization
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username'; // TODO: Add to localization
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters'; // TODO: Add to localization
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _startLooking,
                      onTapOutside: (_) => _stopLooking(),
                      onChanged: _lookAround,
                      decoration: InputDecoration(
                        hintText: l10n.email,
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!value.contains('@')) {
                          return l10n.emailInvalid;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone Field (Optional)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _startLooking,
                      onTapOutside: (_) => _stopLooking(),
                      onChanged: _lookAround,
                      decoration: InputDecoration(
                        hintText: 'Phone (Optional)', // TODO: Add to localization
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.phone_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
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
                        hintText: l10n.password,
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
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onTap: _hidePassword,
                      onTapOutside: (_) => _showPassword(),
                      onEditingComplete: _showPassword,
                      decoration: InputDecoration(
                        hintText: l10n.confirmPassword,
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.white,
                        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Role Selection - Multiple Checkboxes
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.work_outline, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Select Roles',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildRoleCheckbox('user', '👤 User', theme),
                          _buildRoleCheckbox('employer', '💼 Employer', theme),
                          _buildRoleCheckbox('employee', '👔 Employee', theme),
                          _buildRoleCheckbox('doctor', '🩺 Doctor', theme),
                          _buildRoleCheckbox('admin', '⚡ Admin', theme),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
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
                            : Text(
                                l10n.register,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ', // TODO: Add to localization
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.login,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
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

  Widget _buildRoleCheckbox(String roleValue, String roleLabel, ThemeData theme) {
    return CheckboxListTile(
      title: Text(
        roleLabel,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      value: _selectedRoles.contains(roleValue),
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            _selectedRoles.add(roleValue);
          } else {
            // Ensure at least one role is selected
            if (_selectedRoles.length > 1) {
              _selectedRoles.remove(roleValue);
            }
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: theme.colorScheme.primary,
      dense: true,
      contentPadding: EdgeInsets.zero,
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
