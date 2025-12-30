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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String _selectedRole = 'user'; // 'user' | 'player' | 'umpire'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
      }
    });
  }

  Future<void> _handleAuth() async {
    try {
      print('🔵 [AUTH_SCREEN] Starting auth process. isLogin: $isLogin');
      
      if (isLogin) {
        print('🔵 [AUTH_SCREEN] Attempting email login...');
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('✅ [AUTH_SCREEN] Login successful');
      } else {
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
      }
      
      if (!mounted) {
        print('⚠️ [AUTH_SCREEN] Widget not mounted, aborting navigation');
        return;
      }

      print('🔵 [AUTH_SCREEN] Getting user role...');
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
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundCard,
              AppColors.backgroundDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Decorative circles in background
                  Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLogin ? 'Welcome Back!' : 'Join Ballista',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Sign in to continue your journey'
                                : 'Create your account and start sharing',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Auth Toggle Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.backgroundCardAlt,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Toggle Buttons
                        Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCardAlt,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _animatedToggleButton(
                                  selected: isLogin,
                                  label: 'Login',
                                  icon: Icons.login_rounded,
                                  onTap: () {
                                    setState(() => isLogin = true);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _animatedToggleButton(
                                  selected: !isLogin,
                                  label: 'Sign Up',
                                  icon: Icons.person_add_rounded,
                                  onTap: () {
                                    setState(() => isLogin = false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full Name (only for signup)
                                if (!isLogin) ...[
                                  _creativeInput(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    icon: Icons.person_outline_rounded,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Role Selection
                                  Text(
                                    'Select Your Role',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _roleChip(
                                          label: 'User',
                                          value: 'user',
                                          icon: Icons.person_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _roleChip(
                                          label: 'Player',
                                          value: 'player',
                                          icon: Icons.sports_cricket_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _roleChip(
                                          label: 'Umpire',
                                          value: 'umpire',
                                          icon: Icons.gavel_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                
                                // Email Input
                                _creativeInput(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Email is required';
                                    if (!v.contains('@') || !v.contains('.')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Password Input
                                _creativeInput(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Password is required';
                                    if (v.length < 6) return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                                
                                // Forgot Password (only for login)
                                if (isLogin) ...[
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 32),
                                
                                // Submit Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryBlue,
                                        AppColors.primaryBlue.withOpacity(0.8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                isLogin ? 'Sign In' : 'Create Account',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: AppColors.backgroundCardAlt,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Or continue with',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: AppColors.backgroundCardAlt,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Social Login Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _socialButton(
                                        icon: Icons.g_mobiledata,
                                        label: 'Google',
                                        onTap: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _socialButton(
                                        icon: Icons.apple,
                                        label: 'Apple',
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _animatedToggleButton({
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final selected = _selectedRole == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withOpacity(0.15)
                : AppColors.backgroundCardAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : AppColors.backgroundCardAlt,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creativeInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.backgroundDark.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppColors.backgroundCardAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.backgroundCardAlt,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.accentRed,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.accentRed,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.backgroundCardAlt,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
