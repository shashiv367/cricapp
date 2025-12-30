import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  Map<String, dynamic>? _stats;
  String? _playerName;
  String? _teamName;
  String? _profilePictureUrl;
  File? _selectedImage;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProfile(), _loadStats()]);
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
      setState(() {
        _playerName = profile['full_name'] ?? 'Player';
        _nameController.text = profile['full_name'] ?? '';
        _emailController.text = profile['username'] ?? user.email ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _teamName = profile['team_name'] ?? 'Not assigned';
        _teamNameController.text = profile['team_name'] ?? '';
        _profilePictureUrl = profile['profile_picture_url'];
      });
    } catch (_) {
      // ignore for now
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Don't upload yet - wait for user to click "Save Changes"
        // This ensures all fields (team name, profile picture) are updated together
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (_selectedImage == null) return null;

    setState(() => _uploadingImage = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage avatars bucket
      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            _selectedImage!,
          );

      // Get public URL
      final imageUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      setState(() {
        _profilePictureUrl = imageUrl;
        _selectedImage = null; // Clear selected image after upload
        _uploadingImage = false;
      });

      return imageUrl;
    } catch (e) {
      setState(() => _uploadingImage = false);
      throw Exception('Failed to upload image: $e');
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
    _tabController?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      // Upload image if selected
      String? profilePictureUrl = _profilePictureUrl;
      if (_selectedImage != null && !_uploadingImage) {
        profilePictureUrl = await _uploadProfilePicture();
      }

      // Now update profile with all fields including team name and profile picture
      await ApiService.updateProfile(
        token: token,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        teamName: _teamNameController.text.trim().isEmpty 
            ? null 
            : _teamNameController.text.trim(),
        profilePictureUrl: profilePictureUrl,
      );
      
      setState(() {
        _teamName = _teamNameController.text.trim().isEmpty 
            ? 'Not assigned' 
            : _teamNameController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 240,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.backgroundCard,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryBlue.withOpacity(0.3),
                              AppColors.backgroundCard,
                              AppColors.backgroundDark,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Profile Picture
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryBlue,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryBlue.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _profilePictureUrl != null
                                              ? Image.network(
                                                  _profilePictureUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.backgroundCardAlt,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _playerName?.isNotEmpty == true
                                                              ? _playerName!.substring(0, 1).toUpperCase()
                                                              : 'P',
                                                          style: TextStyle(
                                                            color: AppColors.primaryBlue,
                                                            fontSize: 36,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : _selectedImage != null
                                                  ? Image.file(
                                                      _selectedImage!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.backgroundCardAlt,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _playerName?.isNotEmpty == true
                                                              ? _playerName!.substring(0, 1).toUpperCase()
                                                              : 'P',
                                                          style: TextStyle(
                                                            color: AppColors.primaryBlue,
                                                            fontSize: 36,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                        ),
                                      ),
                                      if (_uploadingImage)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.5),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryBlue,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryBlue,
                                            border: Border.all(
                                              color: AppColors.backgroundCard,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Player Name and Team
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _playerName ?? 'Player',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.group_rounded,
                                          color: AppColors.primaryBlue,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _teamName ?? 'Loading...',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: AppColors.textSecondary,
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController!,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primaryBlue,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.dashboard_rounded),
                            text: 'Dashboard',
                          ),
                          Tab(
                            icon: Icon(Icons.person_rounded),
                            text: 'Profile',
                          ),
                        ],
                      ),
                      AppColors.backgroundCard,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController!,
                children: [
                  _buildDashboardTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Overview Cards
          Row(
            children: [
              Expanded(
                child: _statOverviewCard(
                  'Total Runs',
                  _stats?['batting']?['totalRuns']?.toString() ?? '0',
                  Icons.sports_cricket_rounded,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statOverviewCard(
                  'Wickets',
                  _stats?['bowling']?['totalWickets']?.toString() ?? '0',
                  Icons.sports_baseball_rounded,
                  AppColors.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statOverviewCard(
                  'Matches',
                  (_stats?['batting']?['matches'] ?? _stats?['bowling']?['matches'] ?? 0).toString(),
                  Icons.event_rounded,
                  AppColors.accentRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statOverviewCard(
                  'Strike Rate',
                  _stats?['batting']?['strikeRate']?.toString() ?? '0.00',
                  Icons.trending_up_rounded,
                  AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Batting Stats Section
          _buildStatsSection(
            'Batting Statistics',
            Icons.sports_cricket_rounded,
            [
              _statRow('Total Runs', _stats?['batting']?['totalRuns']?.toString() ?? '0'),
              _statRow('Total Balls', _stats?['batting']?['totalBalls']?.toString() ?? '0'),
              _statRow('Strike Rate', _stats?['batting']?['strikeRate']?.toString() ?? '0.00'),
              _statRow('Fours', _stats?['batting']?['totalFours']?.toString() ?? '0'),
              _statRow('Sixes', _stats?['batting']?['totalSixes']?.toString() ?? '0'),
              _statRow('Matches', _stats?['batting']?['matches']?.toString() ?? '0'),
            ],
          ),

          const SizedBox(height: 24),

          // Bowling Stats Section
          _buildStatsSection(
            'Bowling Statistics',
            Icons.sports_baseball_rounded,
            [
              _statRow('Total Wickets', _stats?['bowling']?['totalWickets']?.toString() ?? '0'),
              _statRow('Total Overs', _stats?['bowling']?['totalOvers']?.toString() ?? '0.0'),
              _statRow('Economy', _stats?['bowling']?['economy']?.toString() ?? '0.00'),
              _statRow('Average', _stats?['bowling']?['average']?.toString() ?? '0.00'),
              _statRow('Matches', _stats?['bowling']?['matches']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _inputField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          _inputField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _inputField(
            controller: _phoneController,
            label: 'Mobile Number',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
          ),
          _inputField(
            controller: _teamNameController,
            label: 'Team Name',
            icon: Icons.group_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statOverviewCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.backgroundCardAlt, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String title, IconData icon, List<Widget> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.backgroundCardAlt, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...stats,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
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
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            filled: true,
            fillColor: AppColors.backgroundCardAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.backgroundCardAlt, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _color;

  _SliverAppBarDelegate(this._tabBar, this._color);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
