import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/match_card.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import 'team_screen.dart';
import 'ranking_screen.dart';
import 'user_matches_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PostModel> _posts = [
    PostModel(
      user: 'Ballista Official',
      caption: 'What a yorker to finish it off! 🔥',
      mediaType: MediaType.image,
      mediaUrl: '',
      likes: 128,
      comments: 12,
      saves: 18,
    ),
    PostModel(
      user: 'Cricket Daily',
      caption: 'Slow-mo of that perfect outswinger. Seam position 💯',
      mediaType: MediaType.video,
      mediaUrl: '',
      likes: 256,
      comments: 34,
      saves: 42,
    ),
  ];

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostModel> get _filteredPosts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _posts;
    return _posts.where((post) {
      return post.user.toLowerCase().contains(query) ||
          post.caption.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleLike(PostModel post) {
    setState(() {
      if (post.liked) {
        post.liked = false;
        post.likes = (post.likes - 1).clamp(0, 1000000);
      } else {
        post.liked = true;
        post.likes += 1;
      }
    });
  }

  void _toggleSave(PostModel post) {
    setState(() {
      post.saved = !post.saved;
      post.saves = post.saved
          ? post.saves + 1
          : (post.saves - 1).clamp(0, 1000000);
    });
  }

  Future<void> _showCreatePostDialog() async {
    final captionController = TextEditingController();
    MediaType selectedType = MediaType.video;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text(
            'Create Post',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: captionController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Share a clip, ball, or match thought...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Media type:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Video'),
                    selected: selectedType == MediaType.video,
                    onSelected: (_) =>
                        setDialogState(() => selectedType = MediaType.video),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Image'),
                    selected: selectedType == MediaType.image,
                    onSelected: (_) =>
                        setDialogState(() => selectedType = MediaType.image),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (captionController.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );

    final caption = captionController.text.trim();
    captionController.dispose();

    if (created == true && caption.isNotEmpty && mounted) {
      setState(() {
        _posts.insert(
          0,
          PostModel(
            user: 'You',
            caption: caption,
            mediaType: selectedType,
            mediaUrl: '',
            likes: 0,
            comments: 0,
            saves: 0,
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added locally. Connect backend to persist.')),
      );
    }
  }

  Future<void> _refreshFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmAndLogout() async {
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

    if (confirm != true || !mounted) return;

    try {
      final authService = AuthService();
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _filteredPosts;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search posts or users...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text(
                'Ballista',
                style: TextStyle(
                  color: AppColors.accentYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            tooltip: _isSearching ? 'Close search' : 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _confirmAndLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _showCreatePostDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create post'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                MatchCard(
                  team1: 'India',
                  team2: 'Australia',
                  score1: 152,
                  score2: 148,
                  isLive: true,
                  overs1: '18.3',
                  overs2: '19.0',
                  matchStatus: 'T20 • Bengaluru',
                  subtitle: 'Ind need 12 runs in 11 balls',
                  onTap: () {
                    Navigator.pushNamed(context, '/live-detail');
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quick access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickTile(
                      icon: Icons.sports_cricket,
                      label: 'Live Matches',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserMatchesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickTile(
                      icon: Icons.group,
                      label: 'Teams',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TeamScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickTile(
                      icon: Icons.leaderboard,
                      label: 'Rankings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RankingScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickTile(
                      icon: Icons.sports_score,
                      label: 'All Matches',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserMatchesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Community posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (visiblePosts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No matching posts found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...visiblePosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostCard(
                        post: post,
                        onLike: () => _toggleLike(post),
                        onSave: () => _toggleSave(post),
                        onComment: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment action (demo).')),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
