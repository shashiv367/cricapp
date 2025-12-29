import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class UmpireMatchDetailScreen extends StatefulWidget {
  final String matchId;

  const UmpireMatchDetailScreen({super.key, required this.matchId});

  @override
  State<UmpireMatchDetailScreen> createState() => _UmpireMatchDetailScreenState();
}

class _UmpireMatchDetailScreenState extends State<UmpireMatchDetailScreen> {
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

      final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
      setState(() {
        _match = response['match'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load match: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateScore({
    int? teamAScore,
    int? teamAWkts,
    double? teamAOvers,
    int? teamBScore,
    int? teamBWkts,
    double? teamBOvers,
  }) async {
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      await ApiService.updateMatchScore(
        token: token,
        matchId: widget.matchId,
        teamAScore: teamAScore,
        teamAWkts: teamAWkts,
        teamAOvers: teamAOvers,
        teamBScore: teamBScore,
        teamBWkts: teamBWkts,
        teamBOvers: teamBOvers,
      );

      _loadMatch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update score: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamA = _match!['team_a'] is Map ? _match!['team_a']['name'] : 'Team A';
    final teamB = _match!['team_b'] is Map ? _match!['team_b']['name'] : 'Team B';
    final score = _match!['score'] is Map ? _match!['score'] : null;
    final playerStats = List<Map<String, dynamic>>.from(_match!['playerStats'] ?? []);

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
            const Text(
              'Quick score update',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _quickUpdateButtons(score),
            const SizedBox(height: 24),
            const Text(
              'Player stats',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (playerStats.isEmpty)
              const Text(
                'No player stats yet. Add players to track individual performance.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...playerStats.map((stat) => _playerStatCard(stat)),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(String teamName, Map<String, dynamic> score, bool isTeamA) {
    final scoreVal = isTeamA ? (score['team_a_score'] ?? 0) : (score['team_b_score'] ?? 0);
    final wkts = isTeamA ? (score['team_a_wkts'] ?? 0) : (score['team_b_wkts'] ?? 0);
    final overs = isTeamA ? (score['team_a_overs'] ?? 0.0) : (score['team_b_overs'] ?? 0.0);
    final runRate = isTeamA
        ? (score['team_a_run_rate'] ?? (overs > 0 ? (scoreVal / overs).toStringAsFixed(2) : '0.00'))
        : (score['team_b_run_rate'] ?? (overs > 0 ? (scoreVal / overs).toStringAsFixed(2) : '0.00'));

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
                    'RR: $runRate',
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

  Widget _quickUpdateButtons(Map<String, dynamic>? score) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _updateButton('Team A +1', () {
          final current = score?['team_a_score'] ?? 0;
          _updateScore(teamAScore: current + 1);
        }),
        _updateButton('Team A +4', () {
          final current = score?['team_a_score'] ?? 0;
          _updateScore(teamAScore: current + 4);
        }),
        _updateButton('Team A Wicket', () {
          final current = score?['team_a_wkts'] ?? 0;
          _updateScore(teamAWkts: current + 1);
        }),
        _updateButton('Team A +0.1 ov', () {
          final current = score?['team_a_overs'] ?? 0.0;
          _updateScore(teamAOvers: current + 0.1);
        }),
        _updateButton('Team B +1', () {
          final current = score?['team_b_score'] ?? 0;
          _updateScore(teamBScore: current + 1);
        }),
        _updateButton('Team B +4', () {
          final current = score?['team_b_score'] ?? 0;
          _updateScore(teamBScore: current + 4);
        }),
        _updateButton('Team B Wicket', () {
          final current = score?['team_b_wkts'] ?? 0;
          _updateScore(teamBWkts: current + 1);
        }),
        _updateButton('Team B +0.1 ov', () {
          final current = score?['team_b_overs'] ?? 0.0;
          _updateScore(teamBOvers: current + 0.1);
        }),
      ],
    );
  }

  Widget _updateButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.backgroundCardAlt,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  Widget _playerStatCard(Map<String, dynamic> stat) {
    final name = stat['player_name'] ?? 'Unknown';
    final runs = stat['runs'] ?? 0;
    final balls = stat['balls'] ?? 0;
    final wickets = stat['wickets'] ?? 0;
    final overs = stat['overs'] ?? 0.0;
    final strikeRate = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(2) : '0.00';
    final economy = overs > 0 ? (runs / overs).toStringAsFixed(2) : '0.00';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.backgroundCard,
      child: ListTile(
        title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(
          'Runs: $runs ($balls) | Wkts: $wickets ($overs ov)',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('SR: $strikeRate', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('Eco: $economy', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}



