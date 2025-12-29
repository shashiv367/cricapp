import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/match_card.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
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

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      if (post.liked) {
        post.liked = false;
        post.likes = (post.likes - 1).clamp(0, 1000000);
      } else {
        post.liked = true;
        post.likes += 1;
      }
    });
  }

  void _toggleSave(int index) {
    setState(() {
      final post = _posts[index];
      post.saved = !post.saved;
      post.saves = post.saved ? post.saves + 1 : (post.saves - 1).clamp(0, 1000000);
    });
  }

  void _addMockPost() {
    setState(() {
      _posts.insert(
        0,
        PostModel(
          user: 'You',
          caption: 'Just posted a new clip! 🏏',
          mediaType: MediaType.video,
          mediaUrl: '',
          likes: 0,
          comments: 0,
          saves: 0,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created (demo). Hook this to your backend.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ballista',
          style: TextStyle(
            color: AppColors.accentYellow,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.backgroundCard,
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/auth');
              } else if (value == 'login') {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem(
                value: 'login',
                child: Text('Login'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _addMockPost,
        icon: const Icon(Icons.add),
        label: const Text('Create post'),
      ),
      body: SingleChildScrollView(
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
                        MaterialPageRoute(builder: (_) => const UserMatchesScreen()),
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
                        MaterialPageRoute(builder: (_) => const UserMatchesScreen()),
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
              ...List.generate(_posts.length, (index) {
                final post = _posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    onLike: () => _toggleLike(index),
                    onSave: () => _toggleSave(index),
                    onComment: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment action (demo).')),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTile({required IconData icon, required String label, VoidCallback? onTap}) {
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


