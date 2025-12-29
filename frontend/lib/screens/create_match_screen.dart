import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/match_service.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _matchService = MatchService();

  int scoreA = 0;
  int scoreB = 0;
  int wicketsA = 0;
  int wicketsB = 0;
  double oversA = 0.0;
  double oversB = 0.0;
  String? matchId;
  String? teamAName;
  String? teamBName;
  bool saving = false;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  void _incrementScore(bool isA, int runs) {
    setState(() {
      if (isA) {
        scoreA += runs;
      } else {
        scoreB += runs;
      }
    });
    _pushScore();
  }

  void _incrementWicket(bool isA) {
    setState(() {
      if (isA) {
        wicketsA = (wicketsA + 1).clamp(0, 10);
      } else {
        wicketsB = (wicketsB + 1).clamp(0, 10);
      }
    });
    _pushScore();
  }

  void _incrementOver(bool isA) {
    setState(() {
      if (isA) {
        oversA += 0.1;
        if ((oversA * 10 % 10).round() > 5) oversA = (oversA.truncateToDouble() + 1);
      } else {
        oversB += 0.1;
        if ((oversB * 10 % 10).round() > 5) oversB = (oversB.truncateToDouble() + 1);
      }
    });
    _pushScore();
  }

  Future<void> _pushScore() async {
    if (matchId == null) return;
    try {
      await _matchService.updateScore(
        matchId: matchId!,
        teamAScore: scoreA,
        teamAWkts: wicketsA,
        teamAOvers: oversA,
        teamBScore: scoreB,
        teamBWkts: wicketsB,
        teamBOvers: oversB,
      );
    } catch (_) {
      // ignore for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register match',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _input(
                    controller: _teamAController,
                    label: 'Team A name',
                    icon: Icons.flag,
                  ),
                  _input(
                    controller: _teamBController,
                    label: 'Team B name',
                    icon: Icons.outlined_flag,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _scoreCard(
              title: 'Team A',
              score: scoreA,
              wickets: wicketsA,
              overs: oversA,
              onAddRun: (r) => _incrementScore(true, r),
              onAddWicket: () => _incrementWicket(true),
              onAddOver: () => _incrementOver(true),
            ),
            const SizedBox(height: 12),
            _scoreCard(
              title: 'Team B',
              score: scoreB,
              wickets: wicketsB,
              overs: oversB,
              onAddRun: (r) => _incrementScore(false, r),
              onAddWicket: () => _incrementWicket(false),
              onAddOver: () => _incrementOver(false),
            ),
            const SizedBox(height: 16),
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
                onPressed: saving ? null : _saveMatch,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save match'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundCardAlt,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: matchId == null ? null : _openPlayerStatsSheet,
              child: const Text('Add player stats'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    try {
      final id = await _matchService.createMatch(
        teamAName: _teamAController.text.trim(),
        teamBName: _teamBController.text.trim(),
        venue: null,
        overs: 20,
      );
      setState(() {
        matchId = id;
        teamAName = _teamAController.text.trim();
        teamBName = _teamBController.text.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match saved to Supabase.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save match: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _openPlayerStatsSheet() {
    if (matchId == null) return;
    final _playerName = TextEditingController();
    final _runs = TextEditingController();
    final _balls = TextEditingController();
    final _fours = TextEditingController();
    final _sixes = TextEditingController();
    final _wickets = TextEditingController();
    final _overs = TextEditingController();
    String team = 'A';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add player stats',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Team A'),
                          selected: team == 'A',
                          onSelected: (v) => setModalState(() => team = 'A'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Team B'),
                          selected: team == 'B',
                          onSelected: (v) => setModalState(() => team = 'B'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _modalInput(_playerName, 'Player name'),
                    _modalInput(_runs, 'Runs', keyboardType: TextInputType.number),
                    _modalInput(_balls, 'Balls', keyboardType: TextInputType.number),
                    _modalInput(_fours, 'Fours', keyboardType: TextInputType.number),
                    _modalInput(_sixes, 'Sixes', keyboardType: TextInputType.number),
                    _modalInput(_wickets, 'Wickets', keyboardType: TextInputType.number),
                    _modalInput(_overs, 'Overs', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            await _matchService.addPlayerStat(
                              matchId: matchId!,
                              teamId: team == 'A' ? (teamAName ?? '') : (teamBName ?? ''),
                              playerName: _playerName.text.trim(),
                              runs: int.tryParse(_runs.text) ?? 0,
                              balls: int.tryParse(_balls.text) ?? 0,
                              fours: int.tryParse(_fours.text) ?? 0,
                              sixes: int.tryParse(_sixes.text) ?? 0,
                              wickets: int.tryParse(_wickets.text) ?? 0,
                              overs: double.tryParse(_overs.text) ?? 0.0,
                            );
                            if (mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Player stats saved')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Save player stats'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _modalInput(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
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

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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

  Widget _scoreCard({
    required String title,
    required int score,
    required int wickets,
    required double overs,
    required Function(int) onAddRun,
    required VoidCallback onAddWicket,
    required VoidCallback onAddOver,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$score/$wickets',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                '${overs.toStringAsFixed(1)} ov',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillButton('+1', () => onAddRun(1)),
              _pillButton('+2', () => onAddRun(2)),
              _pillButton('+3', () => onAddRun(3)),
              _pillButton('Four', () => onAddRun(4)),
              _pillButton('Six', () => onAddRun(6)),
              _pillButton('Wicket', onAddWicket, color: AppColors.accentRed),
              _pillButton('+0.1 ov', onAddOver, color: AppColors.primaryBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillButton(String label, VoidCallback onTap, {Color color = AppColors.backgroundCardAlt}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.backgroundCardAlt),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


