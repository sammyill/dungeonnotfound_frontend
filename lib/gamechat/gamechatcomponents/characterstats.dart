import 'package:flutter/material.dart';
import "dnd_characters_panel_parts.dart";

class CharacterStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const CharacterStats({super.key, required this.stats});



  static const List<_StatField> _charstats =  [
  _StatField('Strength','strenght','assets/icons/strength.svg'),
  _StatField('Dexterity','dexterity','assets/icons/dexterity.svg'),
  _StatField('Constitution','constitution','assets/icons/constitution.svg'),
  _StatField('Intelligence','intelligence','assets/icons/intelligence.svg'),
  _StatField('Wisdom','wisdom','assets/icons/wisdom.svg'),
  _StatField('Charisma','charisma','assets/icons/charisma.svg'),
];

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < _charstats.length; i += 2) {
      final _StatField left = _charstats[i];
      final _StatField? right = i + 1 < _charstats.length ? _charstats[i + 1] : null;

     rows.add(
  SizedBox(
    height: 42,
    child: Row(
      children: [
        Expanded(
          child: DNDStatsDisplay(
            iconAssetPath: left.iconPath,
            statName: left.label,
            value: (stats[left.key] ?? '-').toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: right == null
              ? const SizedBox.shrink()
              : DNDStatsDisplay(
                  iconAssetPath: right.iconPath,
                  statName: right.label,
                  value: (stats[right.key] ?? '-').toString(),
                ),
        ),
      ],
    ),
  ),
);

      if (i + 2 <_charstats.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return SizedBox(
      width: 400,
      height: 400,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _StatField {
  final String label;
  final String key;
  final String iconPath;

  const _StatField(this.label, this.key,this.iconPath);
}
