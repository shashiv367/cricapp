import 'supabase_client.dart';

class MatchService {
  Future<String> _createOrGetTeam(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) throw Exception('Team name required');
    final existing = await supabase
        .from('teams')
        .select('id')
        .eq('name', normalized)
        .limit(1);
    if (existing.isNotEmpty) return existing.first['id'] as String;
    final insert = await supabase
        .from('teams')
        .insert({'name': normalized})
        .select('id')
        .single();
    return insert['id'] as String;
  }

  Future<String> createMatch({
    required String teamAName,
    required String teamBName,
    String? venue,
    int overs = 20,
  }) async {
    final teamAId = await _createOrGetTeam(teamAName);
    final teamBId = await _createOrGetTeam(teamBName);
    final match = await supabase.from('matches').insert({
      'team_a': teamAId,
      'team_b': teamBId,
      'venue': venue,
      'overs': overs,
      'status': 'live',
    }).select('id').single();
    final matchId = match['id'] as String;
    await supabase.from('match_score').insert({'match_id': matchId});
    return matchId;
  }

  Future<void> updateScore({
    required String matchId,
    required int teamAScore,
    required int teamAWkts,
    required double teamAOvers,
    required int teamBScore,
    required int teamBWkts,
    required double teamBOvers,
    int? target,
  }) async {
    await supabase.from('match_score').update({
      'team_a_score': teamAScore,
      'team_a_wkts': teamAWkts,
      'team_a_overs': teamAOvers,
      'team_b_score': teamBScore,
      'team_b_wkts': teamBWkts,
      'team_b_overs': teamBOvers,
      if (target != null) 'target': target,
    }).eq('match_id', matchId);
  }

  Future<void> addPlayerStat({
    required String matchId,
    required String teamId,
    required String playerName,
    int runs = 0,
    int balls = 0,
    int fours = 0,
    int sixes = 0,
    int wickets = 0,
    double overs = 0.0,
  }) async {
    await supabase.from('match_player_stats').insert({
      'match_id': matchId,
      'team_id': teamId,
      'player_name': playerName,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'wickets': wickets,
      'overs': overs,
    });
  }
}


