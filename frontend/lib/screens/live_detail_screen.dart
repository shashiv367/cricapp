import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LiveDetailScreen extends StatelessWidget {
  const LiveDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Match Center'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
            tabs: [
              Tab(text: 'Live'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Squads'),
              Tab(text: 'Overs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLiveTab(),
            _buildScorecardTab(),
            _buildSquadsTab(),
            _buildOversTab(),
          ],
        ),
      ),
    );
  }

  static Widget _buildLiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bannerCard(),
          const SizedBox(height: 14),
          _scoreStrip(),
          const SizedBox(height: 14),
          _pillChipsRow(),
          const SizedBox(height: 16),
          _partnershipRow(
            striker: 'Virat Kohli*',
            score: '42 (30)',
            partner: 'Hardik Pandya',
            partnerScore: '15 (10)',
            balls: 'P\'ship 57(33)',
          ),
          const SizedBox(height: 12),
          _bowlerRow(
            name: 'Pat Cummins',
            overs: '3.3',
            maiden: '0',
            runs: '24',
            wickets: '1',
            econ: '6.8',
          ),
          const SizedBox(height: 20),
          _sectionHeader('Commentary'),
          const SizedBox(height: 10),
          _commentaryCard([
            _ballRow('18.3', 'Cummins to Kohli, FOUR, lofted over extra cover'),
            _ballRow('18.2', 'Cummins to Kohli, TWO, flicked through midwicket'),
            _ballRow('18.1', 'Cummins to Pandya, SINGLE, pushed to long-on'),
          ]),
          const SizedBox(height: 10),
          _overSummary('18th over: IND 148/3 (Kohli 37, Pandya 14)'),
        ],
      ),
    );
  }

  static Widget _bannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF0B1220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'India need 12 runs in 11 balls',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8),
          const _LiveBadge(),
        ],
      ),
    );
  }

  static Widget _scoreStrip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Row(
        children: [
          Expanded(child: _teamScore('IND', '152/3', '18.3 ov')),
          Column(
            children: const [
              Text(
                'CRR 8.21',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Target 161',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          Expanded(child: _teamScore('AUS', '160/8', '20.0 ov', alignEnd: true)),
        ],
      ),
    );
  }

  static Widget _pillChipsRow() {
    return Row(
      children: [
        _PillChip(label: 'P\'ship 57(33)'),
        const SizedBox(width: 8),
        _PillChip(label: 'CRR 8.21'),
        const SizedBox(width: 8),
        _PillChip(label: 'RR 6.3'),
      ],
    );
  }

  static Widget _teamScore(String team, String score, String overs, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          team,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Text(
          overs,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static Widget _partnershipRow({
    required String striker,
    required String score,
    required String partner,
    required String partnerScore,
    required String balls,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                striker,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                score,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                partner,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                partnerScore,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balls,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget _bowlerRow({
    required String name,
    required String overs,
    required String maiden,
    required String runs,
    required String wickets,
    required String econ,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statChip('O', overs),
              _statChip('M', maiden),
              _statChip('R', runs),
              _statChip('W', wickets),
              _statChip('ECO', econ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _ballRow(String over, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundCardAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              over,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _overSummary(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget _commentaryCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _statChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  static Widget _buildScorecardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Scorecard'),
          const SizedBox(height: 10),
          _inningsCard(
            title: 'India',
            score: '152/3',
            overs: '18.3 ov',
            runRate: 'CRR 8.21',
            target: 'Target 161',
            batters: const [
              ['Matthew Short (c)*', '43', '31', '4', '0', '138.71'],
              ['Chris Lynn', '4', '4', '0', '0', '100.00'],
              ['Jason Sangha', '0', '2', '0', '0', '0.00'],
              ['Liam Scott', '25', '19', '2', '1', '131.58'],
            ],
            extras: '7 (b 0, lb 5, w 2, nb 0, p 0)',
            total: '83-3 (9.5 overs, RR: 8.44)',
          ),
          const SizedBox(height: 18),
          _sectionHeader('Bowling'),
          const SizedBox(height: 8),
          _bowlingScoreRow('Glenn Maxwell', '2', '0', '14', '0', '7.00'),
          _bowlingScoreRow('Tom Curran', '2.5', '0', '28', '2', '9.90'),
        ],
      ),
    );
  }

  static Widget _inningsCard({
    required String title,
    required String score,
    required String overs,
    required String runRate,
    required String target,
    required List<List<String>> batters,
    required String extras,
    required String total,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.backgroundCardAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overs,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      runRate,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      target,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: AppColors.backgroundCardAlt,
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Batter', style: TextStyle(color: AppColors.textSecondary))),
                Expanded(child: Text('R', textAlign: TextAlign.center)),
                Expanded(child: Text('B', textAlign: TextAlign.center)),
                Expanded(child: Text('4s', textAlign: TextAlign.center)),
                Expanded(child: Text('6s', textAlign: TextAlign.center)),
                Expanded(child: Text('SR', textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...batters.map(
            (b) => _scoreRow(b[0], b[1], b[2], b[3], b[4], b[5]),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Extras: $extras',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _overSummary('Total: $total'),
          ),
        ],
      ),
    );
  }

  static Widget _scoreRow(
    String name,
    String r,
    String b,
    String fours,
    String sixes,
    String sr,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'batting',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(r, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary))),
          Expanded(child: Text(b, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary))),
          Expanded(child: Text(fours, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary))),
          Expanded(child: Text(sixes, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary))),
          Expanded(child: Text(sr, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  static Widget _bowlingScoreRow(
    String name,
    String o,
    String m,
    String r,
    String w,
    String eco,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(o, textAlign: TextAlign.center)),
          Expanded(child: Text(m, textAlign: TextAlign.center)),
          Expanded(child: Text(r, textAlign: TextAlign.center)),
          Expanded(child: Text(w, textAlign: TextAlign.center)),
          Expanded(child: Text(eco, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  static Widget _buildSquadsTab() {
    final left = [
      {'name': 'Matthew Short (c)', 'role': 'Batter'},
      {'name': 'Chris Lynn', 'role': 'Batter'},
      {'name': 'Jason Sangha', 'role': 'Batter'},
      {'name': 'Liam Scott', 'role': 'All-rounder'},
      {'name': 'Alex Ross', 'role': 'Batter'},
      {'name': 'Jamie Overton', 'role': 'Bowling All-rounder'},
      {'name': 'Harry Nielsen (wk)', 'role': 'WK-Batter'},
    ];
    final right = [
      {'name': 'Joe Clarke', 'role': 'WK-Batter'},
      {'name': 'Thomas Fraser Rogers', 'role': 'Batter'},
      {'name': 'Campbell Kellaway', 'role': 'Batter'},
      {'name': 'Marcus Stoinis (c)', 'role': 'Batting All-rounder'},
      {'name': 'Glenn Maxwell', 'role': 'Batting All-rounder'},
      {'name': 'Sam Harper (wk)', 'role': 'WK-Batter'},
      {'name': 'Hilton Cartwright', 'role': 'Batting All-rounder'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Playing XI'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.backgroundCardAlt),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: left.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: index == left.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: AppColors.backgroundCardAlt),
                          ),
                  ),
                  child: Row(
                    children: [
                      _playerTile(left[index]['name']!, left[index]['role']!, alignEnd: false),
                      const SizedBox(width: 12),
                      _playerTile(right[index]['name']!, right[index]['role']!, alignEnd: true),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _playerTile(String name, String role, {required bool alignEnd}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!alignEnd)
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.backgroundCardAlt,
              child: Icon(Icons.person, color: AppColors.textSecondary, size: 18),
            ),
          if (!alignEnd) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
          if (alignEnd) const SizedBox(width: 8),
          if (alignEnd)
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.backgroundCardAlt,
              child: Icon(Icons.person, color: AppColors.textSecondary, size: 18),
            ),
        ],
      ),
    );
  }

  static Widget _buildOversTab() {
    final overs = [
      {
        'over': 'Ov 10',
        'runs': '10 runs',
        'summary': 'Tom Curran to Matthew Short',
        'balls': ['4', '2', '2', '1', '1', '0'],
      },
      {
        'over': 'Ov 9',
        'runs': '9 runs',
        'summary': 'Glenn Maxwell to Matthew Short & Ross',
        'balls': ['2', '0', '0', '1', '4', '1'],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: overs.map((ov) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ov['over']} • ${ov['runs']}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ov['summary'] as String,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (ov['balls'] as List<String>).map((b) {
                    Color bg = AppColors.backgroundCardAlt;
                    if (b == '4') bg = AppColors.primaryBlue;
                    if (b == '6') bg = AppColors.accentGreen;
                    if (b == 'W') bg = AppColors.accentRed;
                    return CircleAvatar(
                      radius: 14,
                      backgroundColor: bg,
                      child: Text(
                        b,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Small live badge used in banner
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  const _PillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundCard),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}



