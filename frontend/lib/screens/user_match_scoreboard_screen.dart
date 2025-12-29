import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class UserMatchScoreboardScreen extends StatefulWidget {
  final String matchId;

  const UserMatchScoreboardScreen({super.key, required this.matchId});

  @override
  State<UserMatchScoreboardScreen> createState() => _UserMatchScoreboardScreenState();
}

class _UserMatchScoreboardScreenState extends State<UserMatchScoreboardScreen> {
  Map<String, dynamic>? _match;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchScoreboard(token: token, matchId: widget.matchId);
      setState(() {
        _match = response['match'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scoreboard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scoreboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scoreboard')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamA = _match!['team_a'] is Map ? _match!['team_a']['name'] : 'Team A';
    final teamB = _match!['team_b'] is Map ? _match!['team_b']['name'] : 'Team B';
    final score = _match!['score'] is Map ? _match!['score'] : null;
    final teamAStats = List<Map<String, dynamic>>.from(_match!['team_a_stats'] ?? []);
    final teamBStats = List<Map<String, dynamic>>.from(_match!['team_b_stats'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('$teamA vs $teamB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatch,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (score != null) ...[
              _scoreCard(teamA, score, true),
              const SizedBox(height: 12),
              _scoreCard(teamB, score, false),
              const SizedBox(height: 24),
            ],
            Text(
              '$teamA - Batting',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _playerStatsTable(teamAStats),
            const SizedBox(height: 24),
            Text(
              '$teamB - Batting',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _playerStatsTable(teamBStats),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(String teamName, Map<String, dynamic> score, bool isTeamA) {
    final scoreVal = isTeamA ? (score['team_a_score'] ?? 0) : (score['team_b_score'] ?? 0);
    final wkts = isTeamA ? (score['team_a_wkts'] ?? 0) : (score['team_b_wkts'] ?? 0);
    final overs = isTeamA ? (score['team_a_overs'] ?? 0.0) : (score['team_b_overs'] ?? 0.0);
    final runRate = isTeamA ? (score['team_a_run_rate'] ?? 0.0) : (score['team_b_run_rate'] ?? 0.0);

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
            teamName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$scoreVal/$wkts',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${overs.toStringAsFixed(1)} ov',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'RR: ${runRate.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerStatsTable(List<Map<String, dynamic>> stats) {
    if (stats.isEmpty) {
      return const Text(
        'No player stats available',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.backgroundCardAlt,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Runs', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Balls', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('SR', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Wkts', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
            ],
          ),
          ...stats.map((stat) {
            final name = stat['player_name'] ?? 'Unknown';
            final runs = stat['runs'] ?? 0;
            final balls = stat['balls'] ?? 0;
            final strikeRate = stat['strike_rate'] ?? (balls > 0 ? ((runs / balls) * 100).toStringAsFixed(2) : '0.00');
            final wickets = stat['wickets'] ?? 0;

            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$runs', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$balls', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$strikeRate', style: const TextStyle(color: AppColors.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$wickets', style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}



