import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'umpire_match_detail_screen.dart';
import 'umpire_match_management_screen.dart';

class UmpireLiveMatchesScreen extends StatefulWidget {
  const UmpireLiveMatchesScreen({super.key});

  @override
  State<UmpireLiveMatchesScreen> createState() => _UmpireLiveMatchesScreenState();
}

class _UmpireLiveMatchesScreenState extends State<UmpireLiveMatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listUmpireMatches(token);
      setState(() {
        _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load matches: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_cricket, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No matches yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UmpireMatchManagementScreen()),
                          ).then((_) => _loadMatches());
                        },
                        child: const Text('Create Match'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMatches,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      final teamA = match['team_a'] is Map ? match['team_a']['name'] : 'Team A';
                      final teamB = match['team_b'] is Map ? match['team_b']['name'] : 'Team B';
                      final status = match['status'] ?? 'live';
                      final location = match['location'] is Map ? match['location']['name'] : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppColors.backgroundCard,
                        child: ListTile(
                          title: Text(
                            '$teamA vs $teamB',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            location != null ? '📍 $location' : 'No location',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: status == 'live'
                                ? AppColors.accentRed.withOpacity(0.2)
                                : AppColors.backgroundCardAlt,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UmpireMatchDetailScreen(matchId: match['id'].toString()),
                              ),
                            ).then((_) => _loadMatches());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

