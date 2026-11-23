import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class AddTeamPlayersScreen extends StatefulWidget {
  final String matchId;
  final String teamName;
  final String? teamId;
  final bool isTeamA;

  const AddTeamPlayersScreen({
    super.key,
    required this.matchId,
    required this.teamName,
    this.teamId,
    required this.isTeamA,
  });

  @override
  State<AddTeamPlayersScreen> createState() => _AddTeamPlayersScreenState();
}

class _AddTeamPlayersScreenState extends State<AddTeamPlayersScreen> {
  final _playerNameController = TextEditingController();
  final List> _players = [];
  final Set<String> _removingPlayerIds = {};

  String? _actualTeamId;
  bool _loadingTeamId = true;
  bool _addingPlayer = false;
  bool _continuing = false;

  Color get _teamAccentColor =>
      widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed;

  @override
  void initState() {
    super.initState();
    _actualTeamId = widget.teamId;
    _initScreenData();
  }

  Future<String?> _getAccessToken() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    return supabase.auth.currentSession?.accessToken;
  }

  Future?> _fetchMatch() async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await ApiService.getMatchDetails(
      token: token,
      matchId: widget.matchId,
    );
    return response['match'] as Map<String, dynamic>?;
  }

  Future<void> _initScreenData() async {
    try {
      final match = await _fetchMatch();
      if (match == null || !mounted) return;

      if (_actualTeamId == null) {
        final teamKey = widget.isTeamA ? 'team_a' : 'team_b';
        final team = match[teamKey] as Map<String, dynamic>?;
        _actualTeamId = team?['id'] as String?;
      }

      _loadPlayersFromMatchData(match);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to load match details: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTeamId = false);
      }
    }
  }

  void _loadPlayersFromMatchData(Map<String, dynamic> match) {
    final currentTeamId = _actualTeamId;
    if (currentTeamId == null) return;

    final playerStats = match['playerStats'] as List<dynamic>? ?? [];
    final teamPlayers = playerStats
        .whereType>()
        .where((stat) => stat['team_id'] == currentTeamId)
        .map((stat) => <String, dynamic>{
              'id': stat['id'],
              'name': stat['player_name'] ?? 'Unknown Player',
            })
        .toList();

    if (!mounted) return;
    setState(() {
      _players
        ..clear()
        ..addAll(teamPlayers);
    });
  }

  Future<void> _addPlayer() async {
    final playerName = _playerNameController.text.trim();
    if (playerName.isEmpty || _actualTeamId == null || _addingPlayer) return;

    setState(() => _addingPlayer = true);
    try {
      final token = await _getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await ApiService.addPlayerToMatch(
        token: token,
        matchId: widget.matchId,
        teamId: _actualTeamId!,
        playerName: playerName,
      );

      final playerStat = response['playerStat'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _players.add({
            'id': playerStat?['id'],
            'name': playerName,
          });
          _playerNameController.clear();
        });
        _showSnackBar('$playerName added successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add player: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _addingPlayer = false);
      }
    }
  }

  Future<void> _removePlayer(int index) async {
    if (index < 0 || index >= _players.length) return;

    final player = _players[index];
    final playerName = (player['name'] ?? 'Player').toString();
    final playerStatId = player['id']?.toString();

    if (playerStatId == null || playerStatId.isEmpty) {
      setState(() => _players.removeAt(index));
      return;
    }

    if (_removingPlayerIds.contains(playerStatId)) return;

    setState(() => _removingPlayerIds.add(playerStatId));
    try {
      final token = await _getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      await ApiService.deletePlayerFromMatch(
        token: token,
        matchId: widget.matchId,
        playerStatId: playerStatId,
      );

      if (mounted) {
        setState(() {
          _players.removeWhere((item) => item['id']?.toString() == playerStatId);
        });
        _showSnackBar('$playerName removed successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to remove player: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _removingPlayerIds.remove(playerStatId));
      }
    }
  }

  Future<void> _continueToNextTeam() async {
    if (_continuing) return;

    if (!widget.isTeamA) {
      Navigator.of(context).popUntil(
        (route) => route.isFirst || route.settings.name == '/umpire-dashboard',
      );
      return;
    }

    setState(() => _continuing = true);
    try {
      final match = await _fetchMatch();
      final teamB = match?['team_b'] as Map<String, dynamic>?;

      if (mounted) {
        if (teamB != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddTeamPlayersScreen(
                matchId: widget.matchId,
                teamName: (teamB['name'] ?? 'Team B').toString(),
                teamId: teamB['id']?.toString(),
                isTeamA: false,
              ),
            ),
          );
        } else {
          _showSnackBar('Team B details not found', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to continue: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _continuing = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.accentRed : AppColors.accentGreen,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _teamAccentColor;

    if (_loadingTeamId) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: Text(
          '${widget.teamName} Players',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withOpacity(0.2),
                    AppColors.backgroundCard,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      size: 48,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teamName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add players to this team',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_players.length} ${_players.length == 1 ? 'player' : 'players'} added',
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add Player & List Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withOpacity(0.15),
                          accent.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accent.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                color: accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Add Player',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _playerNameController,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Enter player name',
                                  hintStyle: TextStyle(color: AppColors.textMuted),
                                  filled: true,
                                  fillColor: AppColors.backgroundCardAlt,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.backgroundCardAlt,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accent,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                onSubmitted: (_) => _addPlayer(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _addingPlayer ? null : _addPlayer,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _addingPlayer
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_players.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.list_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Players (${_players.length})',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_players.length, (index) {
                      final player = _players[index];
                      final playerId = player['id']?.toString();
                      final isRemoving =
                          playerId != null && _removingPlayerIds.contains(playerId);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.backgroundCardAlt,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                (player['name'] ?? '').toString(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            isRemoving
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: accent,
                                    ),
                                  )
                                : IconButton(
            