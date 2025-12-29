import 'package:flutter/material.dart';
import '../widgets/match_card.dart';

class LiveMatchScreen extends StatelessWidget {
  const LiveMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Matches'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MatchCard(
            team1: 'India',
            team2: 'Pakistan',
            score1: 180,
            score2: 172,
            isLive: true,
            overs1: '19.2',
            overs2: '20.0',
            matchStatus: 'Asia Cup • Dubai',
            subtitle: 'Ind need 6 runs in 4 balls',
            onTap: () {
              Navigator.pushNamed(context, '/live-detail');
            },
          ),
          const SizedBox(height: 16),
          MatchCard(
            team1: 'Australia',
            team2: 'England',
            score1: 265,
            score2: 140,
            isLive: true,
            overs1: '50.0',
            overs2: '28.3',
            matchStatus: 'ODI • Sydney',
            subtitle: 'Eng require 126 runs from 21.3 overs',
            onTap: () {
              Navigator.pushNamed(context, '/live-detail');
            },
          ),
        ],
      ),
    );
  }
}


