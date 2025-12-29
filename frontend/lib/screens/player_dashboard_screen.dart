import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) {
        setState(() => _loading = false);
        return;
      }

      final response = await ApiService.getProfile(token);
      final profile = response['profile'];

      _nameController.text = profile['full_name'] ?? '';
      _emailController.text = profile['username'] ?? user.email ?? '';
      _phoneController.text = profile['phone'] ?? '';
    } catch (_) {
      // ignore for now
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getPlayerStats(token: token, playerId: user.id);
      setState(() {
        _stats = response;
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      await ApiService.updateProfile(
        token: token,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Dashboard'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _inputField(
                    controller: _nameController,
                    label: 'Full name',
                    icon: Icons.person_outline,
                  ),
                  _inputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _inputField(
                    controller: _phoneController,
                    label: 'Mobile number',
                    icon: Icons.phone_iphone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
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
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save changes'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your stats',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_stats != null) ...[
                    _statCard(
                      'Batting',
                      [
                        'Total Runs: ${_stats!['batting']?['totalRuns'] ?? 0}',
                        'Total Balls: ${_stats!['batting']?['totalBalls'] ?? 0}',
                        'Strike Rate: ${_stats!['batting']?['strikeRate'] ?? '0.00'}',
                        'Fours: ${_stats!['batting']?['totalFours'] ?? 0}',
                        'Sixes: ${_stats!['batting']?['totalSixes'] ?? 0}',
                        'Matches: ${_stats!['batting']?['matches'] ?? 0}',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      'Bowling',
                      [
                        'Total Wickets: ${_stats!['bowling']?['totalWickets'] ?? 0}',
                        'Total Overs: ${_stats!['bowling']?['totalOvers'] ?? 0.0}',
                        'Economy: ${_stats!['bowling']?['economy'] ?? '0.00'}',
                        'Average: ${_stats!['bowling']?['average'] ?? '0.00'}',
                        'Matches: ${_stats!['bowling']?['matches'] ?? 0}',
                      ],
                    ),
                  ] else
                    const Text(
                      'Loading stats...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, List<String> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...stats.map((stat) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  stat,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
}


