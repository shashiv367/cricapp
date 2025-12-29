import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'umpire_dashboard_screen.dart';
import 'player_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool useEmail = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String _selectedRole = 'user'; // 'user' | 'player' | 'umpire'

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_loading) {
      print('⚠️ [AUTH_SCREEN] Already loading, ignoring submit');
      return;
    }
    setState(() => _loading = true);
    _handleAuth().then((_) {
      print('✅ [AUTH_SCREEN] Auth completed successfully');
      if (mounted) setState(() => _loading = false);
    }).catchError((e, stackTrace) {
      print('❌ [AUTH_SCREEN] Auth error in submit catchError: $e');
      print('❌ [AUTH_SCREEN] Stack: $stackTrace');
      if (mounted) {
        setState(() => _loading = false);
        // Error already shown in _handleAuth, but ensure loading is reset
      }
    });
  }

  Future<void> _handleAuth() async {
    try {
      print('🔵 [AUTH_SCREEN] Starting auth process. isLogin: $isLogin');
      
      if (isLogin) {
        if (useEmail) {
          print('🔵 [AUTH_SCREEN] Attempting email login...');
          await _authService.signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          print('✅ [AUTH_SCREEN] Login successful');
        } else {
          await _authService.verifyPhoneOtp(
            phone: _phoneController.text.trim(),
            token: _otpController.text.trim(),
          );
        }
      } else {
        if (useEmail) {
          print('🔵 [AUTH_SCREEN] Attempting email signup with role: $_selectedRole');
          await _authService.signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            role: _selectedRole,
          );
          print('✅ [AUTH_SCREEN] Signup successful');
        } else {
          // Send OTP if not sent; verify with entered OTP.
          await _authService.verifyPhoneOtp(
            phone: _phoneController.text.trim(),
            token: _otpController.text.trim(),
          );
        }
      }
      
      if (!mounted) {
        print('⚠️ [AUTH_SCREEN] Widget not mounted, aborting navigation');
        return;
      }

      print('🔵 [AUTH_SCREEN] Getting user role...');
      // Decide dashboard based on role after successful auth.
      final role = await _authService.getCurrentRole();
      print('🔵 [AUTH_SCREEN] User role: $role');
      
      Widget target;
      switch (role) {
        case 'umpire':
          print('🔵 [AUTH_SCREEN] Navigating to UmpireDashboard');
          target = const UmpireDashboardScreen();
          break;
        case 'player':
          print('🔵 [AUTH_SCREEN] Navigating to PlayerDashboard');
          target = const PlayerDashboardScreen();
          break;
        case 'user':
        default:
          print('🔵 [AUTH_SCREEN] Navigating to MainScreen (user)');
          target = const MainScreen();
      }

      print('🔵 [AUTH_SCREEN] Performing navigation...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
      print('✅ [AUTH_SCREEN] Navigation complete');
    } catch (e, stackTrace) {
      print('❌ [AUTH_SCREEN] Auth failed: $e');
      print('❌ [AUTH_SCREEN] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth failed: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Rethrow so the .catchError() in _submit() can handle it
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      isLogin ? 'Welcome back' : 'Join Ballista',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin
                          ? 'Login to continue and personalize your feed.'
                          : 'Create your account to share clips and engage.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.backgroundCardAlt),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _toggleButton(selected: isLogin, label: 'Login', onTap: () {
                                setState(() => isLogin = true);
                              }),
                              const SizedBox(width: 12),
                              _toggleButton(selected: !isLogin, label: 'Sign up', onTap: () {
                                setState(() => isLogin = false);
                              }),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (!isLogin)
                                  _input(
                                    controller: _nameController,
                                    label: 'Full name',
                                    icon: Icons.person_outline,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                  ),
                                if (!isLogin)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        _roleChip('User', 'user'),
                                        const SizedBox(width: 8),
                                        _roleChip('Player', 'player'),
                                        const SizedBox(width: 8),
                                        _roleChip('Umpire', 'umpire'),
                                      ],
                                    ),
                                  ),
                                if (!isLogin)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _toggleButton(
                                            selected: useEmail,
                                            label: 'Email',
                                            onTap: () => setState(() => useEmail = true),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _toggleButton(
                                            selected: !useEmail,
                                            label: 'Mobile',
                                            onTap: () => setState(() => useEmail = false),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                _input(
                                  controller: isLogin || useEmail ? _emailController : _phoneController,
                                  label: isLogin || useEmail ? 'Email' : 'Mobile number',
                                  icon: isLogin || useEmail ? Icons.email_outlined : Icons.phone_iphone,
                                  keyboardType: isLogin || useEmail ? TextInputType.emailAddress : TextInputType.phone,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    if (isLogin || useEmail) {
                                      if (!v.contains('@')) return 'Enter a valid email';
                                    } else {
                                      final digits = v.replaceAll(RegExp(r'\\D'), '');
                                      if (digits.length < 10) return 'Enter a valid mobile number';
                                    }
                                    return null;
                                  },
                                ),
                                if (isLogin || useEmail)
                                  _input(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    obscure: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 6) return 'Min 6 characters';
                                      return null;
                                    },
                                  )
                                else ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _input(
                                          controller: _otpController,
                                          label: 'OTP',
                                          icon: Icons.password_outlined,
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Enter OTP';
                                            if (v.length < 4) return 'Enter valid OTP';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryBlue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                      onPressed: _loading
                                          ? null
                                          : () async {
                                              try {
                                                await _authService.sendPhoneOtp(
                                                  phone: _phoneController.text.trim(),
                                                );
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('OTP sent')),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('OTP send failed: $e')),
                                                  );
                                                }
                                              }
                                            },
                                            child: const Text('Send OTP'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(color: AppColors.primaryBlue),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(isLogin ? 'Login' : 'Create account'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Or continue with',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _socialIcon(Icons.g_mobiledata, 'Google'),
                                    const SizedBox(width: 12),
                                    _socialIcon(Icons.apple, 'Apple'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _toggleButton({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue.withOpacity(0.15) : AppColors.backgroundCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.backgroundCardAlt,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String label, String value) {
    final selected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withOpacity(0.15)
                : AppColors.backgroundCardAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.backgroundCardAlt,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.backgroundCardAlt,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.backgroundCardAlt),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundCard),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}


