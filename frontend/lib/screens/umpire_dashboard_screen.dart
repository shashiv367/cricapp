import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'umpire_match_management_screen.dart';
import 'umpire_live_matches_screen.dart';
import 'auth_screen.dart';

class UmpireDashboardScreen extends StatefulWidget {
  const UmpireDashboardScreen({super.key});

  @override
  State<UmpireDashboardScreen> createState() => _UmpireDashboardScreenState();
}

class _UmpireDashboardScreenState extends State<UmpireDashboardScreen> {
  final _authService = AuthService();

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umpire Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match management',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _actionTile(
              context,
              title: 'Create match',
              subtitle: 'Set up teams, select or add location, configure overs.',
              icon: Icons.sports_score,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UmpireMatchManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _actionTile(
              context,
              title: 'My matches',
              subtitle: 'View and manage your created matches, update scores and player stats.',
              icon: Icons.live_tv,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UmpireLiveMatchesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.backgroundCardAlt),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}


